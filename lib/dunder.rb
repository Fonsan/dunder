require 'delegate'
class Dunder
  
  def self.create_lazy_class(klass,instance = nil)
    c = Class.new(DelegateClass(klass)) do 
      def lazy_instance
        # Will be filled in later
      end
      
      def initialize(&block)
        @_thread = Thread.start(&block)
        super(self.lazy_instance)
      end
      
      def __getobj__
        result = @_thread.value
        __setobj__(result) if @_thread.alive?
        
        instance_eval do
          def class
            __getobj__.class
          end
        end
        result
      end
      
    end
    instance ||= klass.new
    def c.lazy_instance
      instance
    end
    c
  end
  
  def self.create_lazy_class!(klass, instance = nil)
    @@lazy_classes[klass] = create_lazy_class(klass,instance)
  end
  
  @@lazy_classes = Hash.new do |hash,key|
    hash[key] = create_lazy_class(key)
  end
  
  # All standard klasses with a constructor having mandatory arguments
  # More to add
  @@default_instances = {
    Integer => 0
  }
  
  @@default_instances.each do |k,v|
    create_lazy_class!(k,v)
  end
  
  def self.load(klass,instance = nil,&block) 
    lazy_class = !@@lazy_classes.key?(klass) && instance ?
       @@lazy_classes[klass] = create_lazy_class(klass,instance)
       :
       @@lazy_classes[klass]
    lazy_class.new(&block)
  end
end
class Dunder::Dispacter
  def initialize(object,klass)
    @_dunder_object = object
    @_dunder_klass = klass
  end
  
  # Maybe theres a better way to do this through delegate
  def method_missing(method_sym, *arguments, &block)
    Dunder.load(@_dunder_klass) do
      @_dunder_object.send(method_sym, *arguments,&block)
    end
  end
end


def String
  def dunder_load(klass = nil)
    klass ||= self.class
    Dunder::Dispacter.new(self,klass)
  end
end

# A non dynamic example for Array
class FutureArray < DelegateClass(Array ) 
  def initialize(&block)
    super(Array.new)
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

