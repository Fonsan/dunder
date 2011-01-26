require 'helper'

class TestDunder < Test::Unit::TestCase
  should "have some simple testing" do
    
     b = "bar"
     
     lazy_b = Dunder.load(String) {
        "bar"
      }
     
     assert_equal b,lazy_b
     puts lazy_b.class
     assert_equal b.class, lazy_b.class
  end
end
