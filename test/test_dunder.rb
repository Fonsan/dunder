require 'helper'
require 'timeout'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:") 
silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 20100819090145) do

    create_table "posts", :force => true do |t|
      t.string "name"
    end

  end
end

class Post < ActiveRecord::Base; end
Post.create!(:name => "hello")

class String
  def heavy
    sleep 0.2
    self
  end
end

class TestDunder < Test::Unit::TestCase
  
  should "have some simple testing" do
     b = "bar"
     lazy_b = nil
     assert_nothing_raised do
       Timeout::timeout(0.1) do
       lazy_b = Dunder.lazy_load {
          sleep 0.2
          "bar"
        }
       end
     end
     sleep 0.3
     assert_equal b,lazy_b
     assert_equal b.class, lazy_b.class
  end
  
  should "respond to dunder_load" do
    assert Object.methods.include?(:dunder_load)
    b = "bar"
    res = nil
    assert_nothing_raised do
      Timeout::timeout(0.1) do
       res = b.dunder_load.heavy
      end
    end
    assert_equal b,res
    assert_equal b.class,res.class
  end
  
  should "respond to methods" do
    lazy_block = Dunder.lazy_load {
      sleep 0.1
      []
    }
    assert lazy_block.respond_to?(:each)
    b = "bar"
    lazy_method = b.dunder_load
    assert lazy_method.respond_to?(:downcase)
  end
  
  should "block when exiting until done" do
    lazy = Dunder.lazy_load {
      sleep 0.1
    }
    assert lazy._thread.alive?
    Dunder::Future.ensure_threads_finished
    assert !lazy._thread.alive?
  end
  
  should "respond to class methods" do
    assert Object.dunder_load.name == Object.name
  end
  
  should "respond to rails" do
    assert Post.scoped.dunder_load.all
    assert Post.dunder_load.all
  end
end
