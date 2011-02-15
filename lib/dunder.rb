require 'delegate'
require 'thread'
class Dunder

  class Future < SimpleDelegator
    @@threads = {}
    FORBIDDEN = [Symbol]
    
    def self.threads
      @@threads
    end
    
    def self.ensure_threads_finished(timeout = nil)
      @@threads.values.each do |t|
        raise 'Thread did not timeout in time' unless t.join(timeout)
      end
    end
    
    attr_reader :_thread
    
    def initialize(group = nil,&block)
      raise ArgumentError,"No block was passed for execution" unless block
      @_thread = group ? group.start_thread(&block) : Thread.start(&block)
      @@threads[@_thread.object_id] = @_thread
    end

    def __getobj__
      # Optimizing a bit
      return super if @delegate_sd_obj
      __setobj__(@_thread.value)
      #@delegate_sd_obj = @_thread.value
      if FORBIDDEN.include?(super.class)
        error = "Your block returned a #{super.class} and because of how ruby handles #{FORBIDDEN.join(", ")}"
        error << " the #{super.class} won't behave correctly. There are two known workarounds:"
        error << " add the suffix ._thread.value or construct the block to return a array of length 1 and say lazy_array.first."
        error << "Ex: puts lazy_object becomes lazy_object._thread.value"
        raise ArgumentError,error
      end
      @@threads.delete @_thread.object_id
      super
    end
    
    def class
      __getobj__.class
    end
  end
  
  class Group
    attr_reader :name,:max
    
    def initialize(max)
      raise ArgumentError,"You must specify a maximum number of threads for this group #{max}" unless max && max.is_a?(Integer)
      @max = max
      @running = 0
      @waiting = []
      @mutex = Mutex.new
    end
    
    def running
      @mutex.synchronize {
        @running
      }
    end
    
    def waiting
      @mutex.synchronize {
        @waiting
      }
    end
    
    def lazy_load(&block)
      Future.new(self,&block)
    end
    
    def start_thread(&block)
      group = self
      Thread.start {
        group.init_thread
        value = block.call
        group.finish_thread
        value
      }
    end
    
    def init_thread
      thread = Thread.current
      waiting = false
      @mutex.synchronize {
        if waiting = (@running >= @max)
          @waiting.push(thread)
        else
          @running += 1
        end
      }
      Thread.stop if waiting
    end
    
    def finish_thread
      thread = Thread.current
      @mutex.synchronize {
        @running -= 1
        unless @waiting.empty?
          # Schedule the next job
          t = @waiting.shift
          @running += 1
          t.wakeup
        end 
      }
    end
  end
  
  # Kernel add exit hook to ensure all threads finishing before exiting
  at_exit do
     Future.ensure_threads_finished
  end
  
  module DunderMethod
    def self.lazy_load(&block)
      Future.new(&block)
    end
  end
  
  def self.lazy_load(&block)
    DunderMethod.lazy_load(&block)
  end
  
  # There maybe a better way of doing this
  class Dispacter < (RUBY_VERSION > "1.9" ? BasicObject : Object)
    def initialize(object,group = nil)
      @_dunder_group = group
      @_dunder_obj = object
    end

    def method_missing(method_sym, *arguments,&block)
      disp = @_dunder_group ? @_dunder_group : DunderMethod
      disp.lazy_load do
        @_dunder_obj.send(method_sym, *arguments,&block)
      end
    end
  end
  
  # http://olabini.com/blog/2011/01/safeer-monkey-patching/
  # This also works for Class methods since: Class.ancestors => [Class, Module, Object, Kernel, BasicObject] 
  module Instance
    def dunder_load(group = nil)
      Dispacter.new(self,group)
    end
  end
  Object.send :include,Instance
  
end