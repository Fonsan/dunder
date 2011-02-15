Dunder
=========================
For tasks that can be started _early_ and evaluated _late_.

A simple way of doing heavy work in a background process and blocking until done when you really need the object.

Preloading using the [proxy pattern](http://sourcemaking.com/design_patterns/proxy)
Heavily inspired by Adam Sandersons [post](http://endofline.wordpress.com/2011/01/18/ruby-standard-library-delegator/)

#### Introduction
To increase performance typically one might want start multiple heavy tasks concurrent.
This is already solvable with threads or the [reactor-pattern](http://rubyeventmachine.com/) but setting this up could be cumbersome or require direct interactions with threads etc.

What inspired me was the ability to run concurrent database queries within a single request in rails, please read more in the section below. 

How you could lazy load something today in ruby 1.9

	foo = "foo"
	bar = "bar"
	t = Thread.start {
		sleep 1
		foo + bar
	}
	# Other code
	foobar = t.value
	
The Thread.start call would not block and execution would continue and when you need the value you could ask t.value for it

Dunder is a simple way of abstracting this but does infact use threads behind the scenes: you simply pass a block to Dunder.lazy_load 
When later accessing the returned object, 
lets say: lazy_object will block until the thread is done and has returned or if the thread is done returns the value. 

Dunder will only be happy under 1.9.* because how blocks changed have changed. There also some caveats that you _should_ read about below

#### Usage

	lazy_object = Dunder.lazy_load {
		# heavy stuff
		value
	}
	# Later on access lazy_object
	puts lazy_object
	puts lazy_object.class # => value.class
	
or through chaining with dunder_load which works for both objects and classes
	
	lazy_sorted_array = array.dunder_load.sort
	
	# With arguments and block
	lazy_obj = obj.dunder_load.do_something_heavy(a,b,c) {
		#maybe something other heavy here
	}
	
Parallel example
	
	lazy_foo = Dunder.lazy_load {
		# Simulate heavy work
		sleep 2
		"foo" 
	}
	
	lazy_bar = Dunder.lazy_load {
		# Simulate heavy work
		sleep 2
		"bar" 
	}
	
	# Do something other heavy

	puts lazy_bar # => "bar"
	puts lazy_bar.class # => String
	puts lazy_foo # => "foo"
	puts lazy_foo.class # => String
	# Will finish after 2 seconds

worth mentioning is that if you access the variable in someway before that it will block earlier
ex

	lazy_array = Dunder.lazy_load do
		sleep 1
		[1,2,3]
	end
	puts lazy_array.length # <- will block here until the above sleep is done
	sleep 1 # other heavy stuff
	puts lazy_array # <- will be printed after 2 seconds
	
changing the order of the statements will fix this though

	lazy_array = Dunder.lazy_load do
		sleep 1
		[1,2,3]
	end
	sleep 1 # other heavy stuff
	puts lazy_array.length # <- will block here until the above sleep in the block is done
	puts lazy_array # <- will be printed after 1 second
	
WARNING "if-it-quacks-like-a-duck-walks-like-a-duck"
====================
* Don't return symbols
* And for normal objects be careful with comparing

The reason for this is that the implementation uses the delegation.rb in ruby which makes objects life tricky. Even though the object return quacks like a object it will not always walk in a straight line.
Ex

	o = Object.new
	res = Dunder.lazy_load { o }
	res == o # => true
	o == res # => false 
	o == res._thread.value # => true

But Array,String,Fixnum,Hash etc work fine.

If you want to be sure that nothing fishy is going on please use ._thread.value

Groups
====================
So now you might be wondering what would happen if we lazy load more than 10000 objects through some intense calculations. Well our performance would decrease because of the [context switching](http://en.wikipedia.org/wiki/Context_switch), it would actually be better if we only ran a limited number of lazy loads at any one point. 

Dunder::Group has been specifically designed to solve this problem.

For our contrived example note that this example and dunder requires a ruby version of at least 1.9.* . Lets say we have list of tens of thousands of urls that we want to visit and measure the sum content length of all the websites

	require 'open-uri'
	list = ["http://google.com","http://yahoo.com", .... ]
	g = Dunder::Group.new(100)
	results = list.map do |u|
	  g.lazy_load { open(u) } 
	  # or dunder_load(g).open(u)
	end
	
	sum = 0
	results.each do |r|
	  sum += r.length
	end
	puts sum

Note that you could use groups by itself and pass blocks 

	g = Dunder::Group.new(4)
	t = g.start_thread {
	  # things to do here
	}

Much depending on what you are doing you will want to pick a higher or lower number. If your task is CPU-bound then around the number of cores on your computer should be optimal, if your task is IO bound which is true for most of my use cases then experimenting is key.

Rails
====================

	# Will not block
	@lazy_posts = Post.dunder_load.all
	
	@lazy_user = User.dunder_load.first
	
and then later in views

	<%= @user.name %> <-  will block until the user have been loaded
	<%= @lazyposts.each do %> <- will block until the posts have been loaded
	...
	<% end %
Be careful not to use the mysql gem which blocks the whole universe on every call. Please use the mysql2 which is the standard adapter for rails since 3.0,
also the pg gem works fine.

For a sample application using mysql checkout [this](https://github.com/Fonsan/dunder-rails-demo)
	
Install
=======
    gem install dunder


(The MIT License)

Copyright (c) 2011 Erik Fonselius

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.