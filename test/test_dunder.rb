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
     puts lazy_b.class
     assert_equal b.class, lazy_b.class
  end
end
