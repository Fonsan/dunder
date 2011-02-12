require 'delegate'
class Dunder
    
  class Future < SimpleDelegator
    @@_threads = {}
    
    def self.threads
      @@_threads
    end
    
    attr_reader :_thread
    
    def initialize(&block)
      @@_threads[(@_thread = Thread.start(&block)).object_id] = @_thread
    end

    def __getobj__
      __setobj__(@_thread.value)
      @@_threads.delete(@_thread.object_id)
      super
    end
    
    def class
      __getobj__.class
    end
    
    def self.ensure_threads_finished
       @@_threads.values.each(&:join)
    end
    
    # Kernel add exit hook to ensure all threads finishing before exiting
    at_exit do
       ensure_threads_finished
    end
  end
  
  module DunderMethod
    def self.lazy_load(&block)
      Future.new(&block)
    end  
  end

  def self.lazy_load(&block)
    DunderMethod.lazy_load(&block)
  end
  
  class Dispacter < (RUBY_VERSION > "1.9" ? BasicObject : Object)
    def initialize(object)
      @_dunder_obj = object
    end

    def method_missing(method_sym, *arguments,&block)
      return if method_sym == :lazy_load
      DunderMethod.lazy_load do
        @_dunder_obj.send(method_sym, *arguments,&block)
      end
    end
  end
  
  # http://olabini.com/blog/2011/01/safeer-monkey-patching/
  # This also works for Class methods since: Class.ancestors => [Class, Module, Object, Kernel, BasicObject] 
  module Instance
    def dunder_load
      Dispacter.new(self)
    end
  end
  Object.send :include,Instance
  
  def self.patch_active_record!
    ActiveRecord::Relation.class_eval do
      delegate :find_by_sql, :to => :dunder_load
    end
  end
end