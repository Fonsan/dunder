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
      Dunder::Future.ensure_threads_finished
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
  
  should "respond to rails" do
    posts = Post.all
    lazy = Dunder.lazy_load do 
      Post.all 
    end
    assert posts == lazy
    assert Post.scoped.dunder_load.all == posts
    assert Post.dunder_load.all == posts
  end
  
  should "do calls in background if ActiveRecord is patched" do
    posts = Post.all
    Dunder.patch_active_record!
    lazy = Post.all
    # Not nice, but for now
    assert Dunder::Future.threads.length > 0
    assert lazy == posts
  end
  
end
