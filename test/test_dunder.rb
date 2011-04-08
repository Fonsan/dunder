require 'helper'
class TestDunder < Test::Unit::TestCase
  
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
  
  should "not raise if user is catching" do
    assert_nothing_raised do
      begin
        res = Dunder.lazy_load {
          raise "should be caught"
          "bar"
        }
        assert res == "bar"
      rescue

      end
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
    assert_equal "bar",lazy
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
