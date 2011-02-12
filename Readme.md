
Dunder
=========================
For tasks that can be started _early_ and evaluated _late_.

A simple way of doing heavy work in a background process and blocking until done when you really need the object.

Preloading using the [proxy pattern](http://sourcemaking.com/design_patterns/proxy)
Heavily inspired by Adam Sandersons [post](http://endofline.wordpress.com/2011/01/18/ruby-standard-library-delegator/)

#### Description
Typically one might want start multiple heavy tasks concurrent.
This is already solvable with threads or the [reactor-pattern](http://rubyeventmachine.com/) but setting this up could be cumbersome or require direct interactions with threads ex.

Dunder is a simple way of abstracting this:
you simply pass a block to Dunder.lazy_load and Dunder will execute this in a thread behind the scenes.
When later accessing the lazy_object will block until the thread is done and has returned or if the thread is done returns the value

The implementation itself relies only on the ruby standard library

Usage

	lazy_object = Dunder.lazy_load {
		# heavy stuff
		value
	}

or through dunder_load
	
	lazy_sorted_array = array.dunder_load.sort
	
	# With arguments and block
	lazy_obj = obj.dunder_load.do_something_heavy(a,b,c) {
		#maybe something other heavy here
	}
	
Paralell example
	
	lazy_foo = Dunder.lazy_load {
		# Simulate heavy IO
		sleep 2
		"foo" 
	}
	
	lazy_bar = Dunder.lazy_load {
		# Simulate heavy IO
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

Known problems

	 Has only been tested with 1.9.2
	
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