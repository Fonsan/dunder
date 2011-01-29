require 'delegate'
class Dunder
  class Future < SimpleDelegator
    def initialize(&block)
      @_thread = Thread.start(&block)
    end

    def __getobj__
      __setobj__(@_thread.value) if @_thread.alive?
      super
    end
    
    def class
      __getobj__.class
    end
  end
  
  def self.load(&block)
    Future.new(&block)
  end
  
  class Dispacter < SimpleDelegator
    def initialize(object)
       @_dunder_obj = object
    end
    
    def class
      @_dunder_obj.class
    end
    
    def method_missing(method_sym, *arguments,&block)
       Dunder.load do
          @_dunder_obj.send(method_sym, *arguments,&block)
       end
    end
  end
  
end

class Object
  def dunder_load
    Dunder::Dispacter.new(self)
  end
end

