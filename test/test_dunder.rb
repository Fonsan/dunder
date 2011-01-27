require 'helper'
require 'timeout'
class TestDunder < Test::Unit::TestCase
  should "have some simple testing" do
     b = "bar"
     lazy_b = nil
     assert_nothing_raised do
       Timeout::timeout(0.5) do
       lazy_b = Dunder.load(String) {
          sleep 1
          "bar"
        }
       end
     end
     assert_equal b,lazy_b
     assert_equal b.class, lazy_b.class
  end
  
  should "respond to dunder_load" do
    assert Object.public_instance_methods.index(:dunder_load)
    b = "bar"
    b.instance_eval do
      def something_heavy
        yield
        self
      end
    end
    res = nil
    assert_nothing_raised do
       Timeout::timeout(0.5) do
       res = b.dunder_load.something_heavy { sleep 1 }
      end
    end
    assert_equal b,res
    assert_equal b.class,res.class
  end
end
