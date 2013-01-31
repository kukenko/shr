Shr
====

Description
-----------
Shr tries to make controlling subprocess easier in Ruby.

 It can be writea shell command as like a Ruby's method and capture subprocess output.

This is a port of Python's sh.


Installation
------------
    gem install shr

Require when needed

```ruby
require 'shr'
```

Usage
-----

Create instance by Shr#shell
```ruby
sh = Shr.shell
```

Run command and capture subprocess output.
```ruby
puts sh.ls
```

Redirect [to|from] file
```ruby
sh.ls > '/tmp/ls_result.txt'
puts sh.cat < '/tmp/ls_result.txt'
```

Pipes are represented by the chain method
```ruby
# cat -n /tmp/ls_result.txt | sort -r
puts sh.cat(:n, '/tmp/ls_result.txt').sort(:r)
```

Bake and run new command
```ruby
sh.bake(:catn,  :cat   [:n])
sh.bake(:sortr, :sort, [:r])
puts sh.catn('/tmp/ls_result.txt').sortr
```

License
-------
Released under the MIT License. See the [LICENSE][license] file for further details.
[license]: https://github.com/kukenko/shr/LICENSE.md
