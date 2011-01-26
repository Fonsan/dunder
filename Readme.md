A simple way of doing heavy work in a background process and when you really need the object it will block until it is done

Preloading using the [proxy pattern](http://sourcemaking.com/design_patterns/proxy)
Heavily inspired by Adam Sandersons [post](http://endofline.wordpress.com/2011/01/18/ruby-standard-library-delegator/)

Dunder
=========================


Usage
=====
	lazy_bar = LazyLoad.load(String) {
		# Simulate heavy IO
		sleep 2
		"bar" 
	}
	puts lazy_bar
Install
=======
    gem install xxxx


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