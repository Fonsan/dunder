require 'helper'
require 'ruby-debug'
class TestDunder < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    Dunder::Future.threads.values.each do |t|
      timeout = 0.5
      unless t.join(timeout)
        raise "#{t} did not finish in #{timeout} seconds"
      end
    end
  end
  
  should "have some simple testing" do
     b = "bar"
     lazy_b = Dunder.lazy_load {
        "bar"
     }
     assert_equal b,lazy_b
     assert_equal b.class, lazy_b.class
  end
  
  should "return a equal object" do
    objects = [Object.new,2,Class,"string",{:foo => "bar"},[1,5],(3..4)]
    objects.each do |o|
      res = Dunder.lazy_load {
        o
      }
      assert_equal o,res._thread.value

      # this works through some serious meta(monkey) programming
      assert_equal res, o
      assert_not_equal o,res unless [Fixnum,String,Hash,Array].include?(o.class) 
    end
  end
  should "raise when returning forbidden objects" do
    assert_raise ArgumentError do
      res = Dunder.lazy_load {
        :bar
      }
      res.inspect
    end
  end
  
  should "duplicate objects fine" do
    objects = ["string",{:foo => "bar"},[1,5]]
    objects.each do |o|
      res = Dunder.lazy_load {
        o
      }
      assert_equal o,res.dup
    end
  end

  
  should "respond to dunder_load" do
    assert Object.methods.include?(:dunder_load)
    b = Moods.new
    res = b.dunder_load.sleepy
    assert_equal b.sleepy,res
    assert_equal b.sleepy.class,res.class
  end
  
  should "respond to methods" do
    lazy_block = Dunder.lazy_load {
      []
    }
    assert lazy_block.respond_to?(:each)
    
    b = "bar"
    lazy_method = b.dunder_load
    assert lazy_method.respond_to?(:downcase)
  end
  
  should "respond to class methods" do
    assert Object.dunder_load.name == Object.name
  end
  
  should "block when exiting until done" do
    m = Mutex.new
    m.lock
    # Lazy Thread
    lazy = Dunder.lazy_load {
      m.lock
    }
    assert lazy._thread.alive?
    m2 = Mutex.new
    
    #Cleaner thread
    Thread.start do
      m2.lock
      Dunder::Future.ensure_threads_finished(1)
      m2.unlock
    end
    
    # Block until cleaner thread has started
    while !m2.locked?
    end
    
    # Let the lazy thread finish
    m.unlock  
    
    # Let the cleaner wait for the lazy thread and wait for the cleaner thread to finish
    m2.lock
    assert !lazy._thread.alive?
  end
  
  should "be nonblocking " do
    m = Mutex.new
    m.lock
    lazy = Dunder.lazy_load {
      m.lock
      m.unlock
      "bar"
    }
    m.unlock
    assert lazy == "bar"
  end
  
  should "still work if block finishes before access" do
    m = Mutex.new
    m.lock
    lazy = Dunder.lazy_load {
      m.lock
      "bar"
    }
    m.unlock
    while lazy._thread.alive?
    end
    assert lazy == "bar"
  end
  
  should "run threads in a group" do
    g = Dunder::Group.new 1
    b = "bar"
    
    lazy = g.lazy_load {
      b
    }
    assert lazy == b
    assert g.running == 0
  end
  
  should "queue threads in group" do
    # When reading the code below it is recommended to reserve 30 min and a coffee
    
    # Create a group with a maximum of 2 threads running
    g = Dunder::Group.new 2
    # Create a mutex control array [[m1,m2],[m1,m2], ... ]
    array = 4.times.map do [Mutex.new,Mutex.new] end
      
    # Lock all the second mutexes
    array.map(&:second).each &:lock
    
    # Start four jobs that try to each lock their specific locks
    results = array.map do |first,second|
      g.lazy_load do
        first.lock
        second.lock
        first
      end
    end
    
    # Wait until 2 of the first locks have been locked
    while array.map(&:first).reject(&:locked?).length != 2 || g.waiting.length != 2
    end
    
    # Assert that only 2 of the threads are running
    assert_equal 2,g.running
    assert_equal 2,g.waiting.length
    
    # Find a the second lock for one of the already locked jobs
    mutex_to_unlock = nil
    for first,second in array
      if first.locked?
        mutex_to_unlock = second
        break
      end
    end
    
    # Unlock the second lock and whatch how a one job finishes and another one gets scheduled
    mutex_to_unlock.unlock
    while g.waiting.length == 2
    end
    assert_equal 1,g.waiting.length
    assert_equal 2,g.running
    
    # Unlock the rest of the second locks
    array.map(&:second).reject do |m|
      m == mutex_to_unlock 
    end.each &:unlock
    
    # Wait for all threads to finish
    assert_not_equal array.map(&:first), results
    assert_equal results,array.map(&:first)
    assert g.waiting.length == 0
    assert g.running == 0
  end
  
  should "limit number of running threads in a Group" do
    g = Dunder::Group.new 1
    srand 123
    count = 32
    enum = 10.times
    result = []
    array = enum.map do |i|
      Dunder.lazy_load {
        sleep(rand * 0.001)
        result << i
        i
      }
    end  
    assert_equal enum.to_a,array 
    # Since we are only running one thread at a time they should come in order
    assert_not_equal enum.to_a,result, "Since we seeded srand this should not happen but could because of thread scheduling"
    assert g.running == 0
    assert g.waiting.length == 0
    
  end
  
  should "respond to rails" do
    posts = Post.all
    lazy = Dunder.lazy_load do 
      Post.all 
    end
    
    assert posts == lazy
    assert Post.scoped.dunder_load.all == posts
    assert Post.dunder_load.all == posts
  end
  
end
