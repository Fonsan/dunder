require 'helper'
require 'timeout'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory") 

ActiveRecord::Schema.define(:version => 20100819090145) do

  create_table "posts", :force => true do |t|
    t.string "name"
  end

end

class Post < ActiveRecord::Base; end

Post.create!(name: "hello")

class TestDunder < Test::Unit::TestCase
  should "have some simple testing" do
     b = "bar"
     lazy_b = nil
     assert_nothing_raised do
       Timeout::timeout(0.1) do
       
       lazy_b = Dunder.load {
          sleep 0.2
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
       Timeout::timeout(0.2) do
       res = b.dunder_load.something_heavy { sleep 0.1}
      end
    end
    assert_equal b,res
    assert_equal b.class,res.class
  end
  
  should "respond to rails" do
    #assert Post.scoped.dunder
    #assert Post.dunder
  end
end
