A simple way of doing heavy work in a background process and blocking until done when you really need the object.

Preloading using the [proxy pattern](http://sourcemaking.com/design_patterns/proxy)
Heavily inspired by Adam Sandersons [post](http://endofline.wordpress.com/2011/01/18/ruby-standard-library-delegator/)

Dunder
=========================
For tasks that can be started early and evaluated late.

Typically one might want start multiple heavy tasks concurrent.
This is already solvable with threads or the [reactor-pattern](http://rubyeventmachine.com/) but setting this up could be cumbersome or require direct interactions with threads ex.

Dunder is a simple way of abstracting this:
you simply pass a block to Dunder.load with the expected class as the argument

Usage

	Dunder.load(Klass,instance = klass.new) {
		# heavy stuff
		value # value must be of Klass
	}

or	

	lazy_obj = obj.dunder_load.do_something_heavy(a,b,c) {
		#maybe something other heavy here
	}
	
	lazy_sorted_articles = @articles.dunder_load.sort_by do |a|
		a.title
	end
	
	lazy_sorted_array = array.dunder_load.sort
	
This is still very beta, any bug reports or patches are welcome
	
Read more further down
	
	lazy_foo = Dunder.load(String) {
		# Simulate heavy IO
		sleep 2
		"foo" 
	}
	
	
	lazy_bar = Dunder.load(String) {
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
	lazy_array = Dunder.load(Array) do
		sleep 1
		[1,2,3]
	end
	puts lazy_array.length # <- will block here until the above sleep is done
	sleep 1 # other heavy stuff
	puts lazy_array # <- will be printed after 2 seconds
	
changing the order will fix this though

	lazy_array = Dunder.load(Array) do
		sleep 1
		[1,2,3]
	end
	sleep 1 # other heavy stuff
	puts lazy_array.length # <- will block here until the above sleep in the block is done
	puts lazy_array # <- will be printed after 1 second
	
API
	Dunder.load(Klass,instance = nil) {
		#things to do
		value
	}
Klass must be the class of value
instance, During the process Dunder will call Klass.new if your class has a mandatory argument in initialize (the constructor) you could create a dummy instance yourself or you could set the return type to Array and return [value] and then use Dunder.load(Array) do [value] end.first
	
Rails
====================

	@lazy_posts = Dunder.load(Array) do
		Post.all
	end
	@lazy_users = Dunder.load(Array) do
		User.all
	end
	
and then later in views

	<%= @lazyposts.each do %> <- this will block until the posts have been loaded
	...
	<% end %>
	

Known problems

it works with most types but has only been tested with 1.9.2
Integer fails with
	NotImplementedError: super from singleton method that is defined to multiple classes is not supported; 
	this will be fixed in 1.9.3 or later	
Or a SystemStackError: stack level too deep
	
Install
=======
    gem install dunder


(The MIT License)

Copyright (c) 2001-2006 Erik Fonselius

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