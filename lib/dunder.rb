# From http://endofline.wordpress.com/2011/01/18/ruby-standard-library-delegator/
require 'delegate'

class FutureArray < DelegateClass(Array ) 
  def initialize(&block)
    @_thread = Thread.start(&block)
  end
  
  def __getobj__
    __setobj__(@_thread.value) if @_thread.alive?
    super
  end
end

class LazyLoad
  
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
        __setobj__(@_thread.value) if @_thread.alive?
        super
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
=begin
{
  String => lambda { "hello" },
  Integer => lambda { 1 }
}

puts LazyLoad.load(String) {
  "hello"
}

puts LazyLoad.load(Integer) {
  1
}

  puts LazyLoad.load(String) {
    #Slow
    sleep 2
    "fubar"
  }

=end