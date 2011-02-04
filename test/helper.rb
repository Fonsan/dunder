require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'timeout'
require 'active_record'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dunder'


DBFILE ="test/test.sqlite3"
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => DBFILE)

unless File.exists? DBFILE
  silence_stream(STDOUT) do 
    ActiveRecord::Schema.define do
      create_table "posts", :force => true do |t|
          t.string "name"
      end
    end
  end
  class Post < ActiveRecord::Base; end
  
  Post.create!(:name => "hello")
end


class Post < ActiveRecord::Base; end

class Moods
  def sleepy
    "bar"
  end
end

class Test::Unit::TestCase
end
