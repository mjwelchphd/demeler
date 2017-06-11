# Demeler Gem

### Copyright (c) 2017 Michael J Welch, Ph.D. mjwelchphd@gmail.com
All files in this distribution are subject to the terms of the MIT license.

This gem builds HTML code on-the-fly. The advantages are: (1) HTML code is properly formed with respect to tags and nesting; and (2) the code is dynamic, i.e., values from an object containing data (if used) are automatically extracted and inserted into the resultant HTML code, and (3) if there are errors, the error message is generated also.

The French word démêler means "to unravel," and that's sort of what this gem does. Démêler is pronounced "day-meh-lay." It unravels your inputs to form HTML code. The diacritical marks are not used in the name for compatibility.

This class doesn't depend on any particular framework, but I use it with Ruby Sequel.


## The Demeler gem generates HTML from three inputs:
* A Ruby source file you write;
* A Hash-based object you provide, like Sequel::Model objects
* An errors list inside the Hash-based object

Let's start with the most basic form, a simple example. Run `irb` and enter this:

```ruby
require 'demeler'
html = Demeler.build(nil,true) do
  html do
    head do
      title "Hello, World!"
    end
    body do
      h1 "Hello, World!"
    end
  end
end
puts html
```

You'll get the html code like this:

```html
<!-- begin generated output -->
<html>
 <head>
  <title>Hello, World!</title>
 </head>
 <body>
  <h1>Hello, World!</h1>
 </body>
</html>
<!-- end generated output -->
```

### Why bother with Demeler? Why not just write HTML?

There are several reasons to use this gem:

* You write in Ruby code
* Demeler balances out all the HTML tags
* Demeler optionally formats the HTML, producing human readable output
* Demeler can receive an object with data (such as a Sequel::Model object), and automatically insert the values
* Demeler can insert error messages your controller inserts into the object

## You can also use the gem directly

You can instantiate a Demeler object, and call its methods:

```ruby
require 'demeler'
d = Demeler.new
d.html do
  d.head do
    d.title("Hello, World!")
  end
  d.body do
    d.h1("Hello, World!")
  end
end
puts d.to_html
```

## Fields from an object can be inserted automatically

You can automatically load the values from a Sequel::Model object, or you can define an object and use it in place of Sequel. To define an object, use a definition similar to this:

```ruby
  class Obj<Hash
    attr_accessor :errors
    def initialize
      @errors = {}
    end
  end
```

Your new object is just a Hash+, so you can assign it values like this:

```ruby
  obj = Obj.new
  obj[:username] = "michael"
  obj[:password] = "my-password"
```

The object can now be used to fill `input` fields in a form:

```ruby
  html = Demeler.build(obj,true) do
    text :username
    password :password
  end
  puts html
```

That code will automatically insert the values from `obj` for you.

> _NOTE: When the first argument is a symbol, it is used as the name of the field._

```html
<!-- begin generated output -->
<input name="username" type="text" value="michael" />
<input name="password" type="password" value="my-password" />
<!-- end generated output -->
```

### Demeler creates error messages, too

You can put an error message into the object you created if your validation finds something wrong. Just insert a Hash element with the name of the element, and an array of lines, thusly:

```ruby
  obj = Obj.new
  obj[:username] = "michael"
  obj[:password] = "my-password"
  obj.errors[:username] = ["This username is already taken"]
  
  html = Demeler.build(obj,true) do
    text :username
    password :password
  end
  puts html
```

This will generate the HTML with the added message, as well:

```html
<!-- begin generated output -->
<input name="username" type="text" value="michael" /><warn> <-- This username is already taken</warn>
<input name="password" type="password" value="my-password" />
<!-- end generated output -->
```

Notice that the error is surrounded by `<warn>...</warn>` tags. You can define how you want those to format the message using CSS. For example, if you just want the message to be displayed in red, use:

```ruby
  style "warn {color: red;}"
```

in your Demeler code like this:

```ruby
  html = Demeler.build(obj,true) do
    style "warn {color: red;}"
    text :username
    password :password
  end
  puts html
```

## Adding attributes to your tags

You can add attributes by just adding them to the end of the tag. For example, if I want the username input tag to display in with a blue background, I can use:

```ruby
  html = Demeler.build(obj,true) do
    style ".blue {color: blue;}"
    text :username, :class=>"blue"
    password :password
  end
  puts html
```

The HTML code generated will be:

```html
<!-- begin generated output -->
<style>.blue {color: blue;}</style>
<input name="username" class="blue" type="text" value="michael" /><warn> <-- This username is already taken</warn>
<input name="password" type="password" value="my-password" />
<!-- end generated output -->
```

Any attribute can be added in this way.

## Embedding text between tags on one line

Normally, anything in brackets {} is embedded like this: `p{"Some text."}` yields:

```html
<!-- begin generated output -->
<p>
 Some text.
</p>
<!-- end generated output -->
```

You can make it come out on one line by using the :text attribute: `p :text=>"Some text."` yields:

```html
<!-- begin generated output -->
<p>Some text.</p>
<!-- end generated output -->
```

In most cases, this can be achieved just by eliminating the {}: `p "Some text." yields:

```html
<!-- begin generated output -->
<p>Some text.</p>
<!-- end generated output -->
```

This is because the solo string is converted to a :text argument automatically.


## Demeler Interface Definitions

The Demeler gem accepts any random tag you want to give it, but non-input tags and input tags are treated differently. Input tags are :button, :checkbox, :color, :date, :datetime_local, :email, :hidden, :image, :month, :number, :password, :range, :radio, :reset, :search, :select, :submit, :tel, :text, :time, :url, and :week. All other tags are non-input tags.

Input tags are treated differently because they have special characteristics, like automatically setting from a form object passed to Demeler. Therefore, we'll start with non-input tags first.

Non-input tags can accept a variety of parameter arrangements to allow for different situations. Each different situation is described below, and there are examples to help you understand.

### Non-Input Tag Parameter Formats

#### tag opts

_Opts is a Hash with attributes._

```ruby
puts (Demeler.build(nil, true) do
  div :class=>"div-class" do
    "..."
  end
end)

<!-- begin generated output -->
<div class="div-class">
 ...
</div>
<!-- end generated output -->
```
#### tag

_A solo tag._

```ruby
puts (Demeler.build(nil, true) do
  br
end)

<!-- begin generated output -->
<br />
<!-- end generated output -->
```

#### tag string

_A solo string._

```ruby
puts (Demeler.build(nil, true) do
  p "This is a paragraph."
end)

<!-- begin generated output -->
<p>This is a paragraph.</p>
<!-- end generated output -->
```

_Or for longer text, you can use the block format._

```ruby
puts (Demeler.build(nil, true) do
  p { "Un débris de hameau où quatre maisons fleuries d'orchis émergent des blés drus et hauts. Ce sont les Bastides Blanches, à mi-chemin entre la plaine et le grand désert lavandier, à l'ombre des monts de Lure. C'est là que vivent douze personnes, deux ménages, plus Gagou l'innocent." }
end)

<!-- begin generated output -->
<p>
 Un débris de hameau où quatre maisons fleuries d'orchis émergent des blés drus et hauts. Ce sont les Bastides Blanches, à mi-chemin entre la plaine et le grand désert lavandier, à l'ombre des monts de Lure. C'est là que vivent douze personnes, deux ménages, plus Gagou l'innocent.
</p>
```

#### tag symbol

_The symbol is used as the name of the tag._ This option is used with input tags (see below).

#### tag symbol, hash

_This option generates_


#### tag symbol, string

_This option generates a tag with the name **symbol**, and the string between beginning and ending tags. If the tag is a :label, and the `label for` matches an `input name`, if the `input` has no `id`, one will be added.

```ruby
puts (Demeler.build(nil, true) do
  label :username, "Enter Username"
  text :username
end)

<!-- begin generated output -->
<label for="username">Enter Username</label>
<input name="username" type="text" id="username" />
<!-- end generated output -->
```

_Tags other than `label` will have a `name` attribute instead of a `for` attribute._

## A Bigger Example of a Demeler Script

### Generate a login screen.

This example will be expanded in the future.

The Ruby code:

```ruby
html = Demeler.build(nil,true) do
  h1("Please Login")
  form(:method=>:post, :action=>"/authenticate") do
    table do
      tr do
        td { label(:username, "User Name") }
        td { text(:username, :size=>30) }
      end

      tr do
        td { label(:password, "Password") }
        td { password(:password, :size=>30) }
      end

      tr do
        td {}
        td { submit("Log In") }
      end
    end
  end
  p { alink("Forgot password?", :href=>"/forgot") }
end
```

The generated HTML:

```html
<!-- begin generated output -->
<h1>Please Login</h1>
<form method="post" action="/authenticate">
 <table>
  <tr>
   <td>
    <label for="username">User Name</label>
   </td>
   <td>
    <input name="username" size="30" type="text" id="username" />
   </td>
  </tr>
  <tr>
   <td>
    <label for="password">Password</label>
   </td>
   <td>
    <input name="password" size="30" type="password" id="password" />
   </td>
  </tr>
  <tr>
   <td>
   </td>
   <td>
    <input type="submit" value="Log In" />
   </td>
  </tr>
 </table>
</form>
<p>
 <a href="/forgot">Forgot password?</a>
</p>
<!-- end generated output -->
```
