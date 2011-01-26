require 'helper'

class TestDunder < Test::Unit::TestCase
  should "have some simple testing" do
     assert_equal "bar",Dunder.load(String) {
       "bar"
     }
  end
end
