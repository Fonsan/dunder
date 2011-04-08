require 'helper'
class TestDunderGroup < Test::Unit::TestCase

  should "run threads in a group" do
    g = Dunder::Group.new 1
    b = "bar"

    lazy = g.lazy_load {
      b
    }
    assert lazy == b
    assert g.running == 0
  end

  should "be able to run just normal threads" do
    g = Dunder::Group.new(2)
    b = "bar"
    t = g.start_thread {
      b
    }
    assert b, t.value
  end

  should "queue next thread upon thread crashing from exception" do
    g = Dunder::Group.new(1)

    g.lazy_load {
      Thread.current.kill
    }
    m = Mutex.new
    assert_raise RuntimeError do
      
      res = g.lazy_load {
        raise "my voice"
        
      }
      while res._thread.alive?
        
      end
      
    end
    res = g.lazy_load {
      true
    }
    assert res
  end

  should "queue threads in group" do
    # When reading the code below it is recommended to reserve 30 min and a coffee

    # Create a group with a maximum of 2 threads running
    g = Dunder::Group.new 2
    # Create a mutex control array [[m1,m2],[m1,m2], ... ]
    array = 4.times.map do
      [Mutex.new, Mutex.new]
    end

    # Lock all the second mutexes
    array.map(&:second).each &:lock

    # Start four jobs that try to each lock their specific locks
    results = array.map do |first, second|
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
    assert_equal 2, g.running
    assert_equal 2, g.waiting.length

    # Find a the second lock for one of the already locked jobs
    mutex_to_unlock = nil
    for first, second in array
      if first.locked?
        mutex_to_unlock = second
        break
      end
    end

    # Unlock the second lock and whatch how a one job finishes and another one gets scheduled
    mutex_to_unlock.unlock
    while g.waiting.length == 2
    end
    assert_equal 1, g.waiting.length
    assert_equal 2, g.running

    # Unlock the rest of the second locks
    array.map(&:second).reject do |m|
      m == mutex_to_unlock
    end.each &:unlock

    # Wait for all threads to finish
    assert_not_equal array.map(&:first), results
    assert_equal results, array.map(&:first)
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
    assert_equal enum.to_a, array
    # Since we are only running one thread at a time they should come in order
    assert_not_equal enum.to_a, result, "Since we seeded srand this should not happen but could because of thread scheduling"
    assert g.running == 0
    assert g.waiting.length == 0

  end

end
