# Demeler Gem

**Copyright (c) 2017 Michael J Welch, Ph.D. <mjwelchphd@gmail.com>**

_NOTE: I appologize that the documentation isn't better than it is, but I'm running way behind in my work trying to make this into a gem in order to preserve and share it._

All files in this distribution are subject to the terms of the MIT license.

This gem builds HTML code on-the-fly. The advantages are:

1. HTML code is properly formed with respect to tags and nesting;
2. the code is dynamic, i.e., values from an object containing data (if used) are automatically extracted and inserted into the resultant HTML code; and
3. if there are errors, the error message is generated also.

The French word démêler means "to unravel," and that's sort of what this gem does. Démêler is pronounced "day-meh-lay." It unravels your inputs to form HTML code. The diacritical marks are not used in the name for compatibility.

This class doesn't depend on any particular framework, but I use it with Ruby Sequel.


## The Demeler gem generates HTML from three inputs:
* A Ruby source file you write;
* A Hash-based object you provide, like Sequel::Model objects; and
* An errors list inside the Hash-based object.

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

## Passing Variables into Demeler

There are three variables you'll be interested in in Demeler.

* `obj` The object, if any, that was passed as parameter 1 in `new` or `build`. I talk a little more about that one below.
* `usr` The object, if any, that was passed as parameter 3 in `build` or parameter 2 in `new`. This object can be anything you need access to in the Demeler script. If you need to pass several objects, simply put them into an array or hash and pass that.
* `out` This is an array where the intermediate results are held internally. To convert the array onto a String, use `to_s` or `to_html` if you created the Demeler object with `new`, and set parameter 2 to false or true if you used `build`.

For example,

```ruby
countries = ['USA', 'Canada', 'France']
Demeler.build(nil, true, countries) do
  p usr.inspect
end
```

 will generate:
 
```html
 <!-- begin generated output -->
<p>["USA", "Canada", "France"]</p>
<!-- end generated output -->
```

If you have more than one thing to pass into Demeler, put your things into an Array or Hash. For example, say you have two lists of countries and cities, you can pass them in a hash (Ruby's default) like this:

```ruby
countries = ['USA', 'Canada', 'France']
cities = ['Los Angeles', 'Paris', 'Berlin']
Demeler.build(nil, true, :countries=>countries, :cities=>cities) do
  p usr[:countries].inspect
  p usr[:cities].inspect
end
```

The output is

```html
<!-- begin generated output -->
<p>["USA", "Canada", "France"]</p>
<p>["Los Angeles", "Paris", "Berlin"]</p>
<!-- end generated output -->
```

Note that the array is named `data` outside of Demeler, but once it's passed in through parameter 3 (usr) of `build`, inside Demeler it's name is `usr`.

## Fields from an object can be inserted automatically

First, a word of warning: if you use variables other than those below, you script will crash. If your script crashes, don't blame Demeler first; look in your script for variables that shouldn't be there.

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
  something = Obj.new
  something[:username] = "michael"
  something[:password] = "my-password"
```

The object can now be used to fill `input` fields in a form:

```ruby
  html = Demeler.build(something,true) do
    text :username
    password :password
  end
  puts html
```

That code will automatically insert the values from `obj` for you.

```html
<!-- begin generated output -->
<input name="username" type="text" value="michael" />
<input name="password" type="password" value="my-password" />
<!-- end generated output -->
```

> _NOTE: When the first argument is a symbol, it is used as the name of the field. Also, the form object is called `something` on the outside, but when we pass it through, it's name is `obj` on the inside._

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

Normally, anything in brackets {} is embedded like this; `p{"Some text."}` yields:

```html
<!-- begin generated output -->
<p>
 Some text.
</p>
<!-- end generated output -->
```

You can make it come out on one line by using the `:text` attribute; `p :text=>"Some text."` yields:

```html
<!-- begin generated output -->
<p>Some text.</p>
<!-- end generated output -->
```

In most cases, this can be achieved just by eliminating the {}; `p "Some text." yields:

```html
<!-- begin generated output -->
<p>Some text.</p>
<!-- end generated output -->
```

This is because the solo string is converted to a :text argument automatically.

## How to create an input control

A standard input control is just a tag and options. Take the `text` control, for example.

`text :username, :size=>30, :value=>"joe.e.razsolli"` => `<input name="username" size="30" value="joe.e.razsolli" type="text" />`

The button, color, date, datetime_local, email, hidden, image, month, number, password, range, reset, search, submit, tel, text, time, url, and week tags all work the that way.

The textarea control, on the other hand, puts it's value between the tags, so it uses a :text attribute instead of a :value attribute.

`textarea :username, :size=>30, :text="joe.e.razsolli` => `<textarea name="username" size="30">joe.e.razsolli</textarea>`

The textarea tag can take its text from a block, also.

`textarea(:username, :size=>30) { "joe.e.razsolli" }` => `<textarea name="username" size="30">joe.e.razsolli</textarea>`

Notice for the block form, you have to enclose the parameters to the textarea call in parenthesis.

## How to Create a Checkbox, Radio, or Select Control

For a checkbox, radio, or select control, use the formats below.

`checkbox(:vehicle, opts, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")` =>
```html
<input name="vehicle[1]" type="checkbox" value="volvo">Volvo</input>
<input name="vehicle[2]" type="checkbox" value="saab">Saab</input>
<input name="vehicle[3]" type="checkbox" value="mercedes">Mercedes</input>
<input name="vehicle[4]" type="checkbox" value="audi">Audi</input>
```

`radio(:vehicle, opts, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")` =>
```html
<input name="vehicle" type="radio" value="volvo">Volvo</input>
<input name="vehicle" type="radio" value="saab">Saab</input>
<input name="vehicle" type="radio" value="mercedes">Mercedes</input>
<input name="vehicle" type="radio" value="audi">Audi</input>
```

`select(:vehicle, opts, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")` =>
```html
<select name="vehicle">
 <option value="volvo">Volvo</option>
 <option value="saab">Saab</option>
 <option value="mercedes">Mercedes</option>
 <option value="audi">Audi</option>
</select>
```

Opts represents a Hash with tag attributes.



## Reference Guide

### def self.build(obj=nil, gen_html=false, usr=nil, &block)

This is the main Demeler call used to build your HTML. This call uses your code in the block, so it makes no sense to call `build` without a block.

Name | Type | Value
---- | ---- | -----
obj | Hash+ | An object to use to get values and error messages.
gen_html | Boolean | Create formatted HTML (true), or compact HTML (false: default).
usr | * | A variable meant to pass a session in a web server, but you can use it for passing any other value as well. _This value is for the caller's use and is not used by Demeler._
block | Proc | The block with your code.

### def initialize(obj=nil, usr=nil, &block)

Initialize sets up the initial conditions in Demeler, and is called by `new`.

Name | Type | Value
---- | ---- | -----
obj | Hash+ | An object to use to get values and error messages.
usr | Hash | A variable meant to pass a session in a web server, but you can use it for passing any other value as well. _This value is for the caller's use and is not used by Demeler._
block | Proc | The block with your code.

### def clear

Clear resets the output variables in order to reuse Demeler without having to reinstantiate it.

### method_missing(meth, *args, &block)

This is a Ruby method which catches method calls that have no real method. For example, when you code a `body` tag, there is no method in Demeler to handle that, so it is caught be `missing_method`. Missing_method passes the call along to `tag_generator` to be coded.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The name of the missing method being caught.
*args | Array | An array of arguments from the call that was intercepted. Tag_generator will try to make sense of them.
block | Proc | The block with your code.

### def p(*args, &block)

The `p` method is a workaround to make 'p' tags work in `build`.

Name | Type | Value
---- | ---- | -----
*args | Array | An array of arguments from the call that was intercepted. Tag_generator will try to make sense of them.
block | Proc | The block with your code.

### def alink(text, args={}, parms={})

The `alink` method is a shortcut to build an `a` tag. You could also write a `a` tag like so:

```ruby
Demeler.build do
  a(:href=>"/") { "Home" }
end
```

but the alink method is a shortcut. Code it like this:

```ruby
Demeler.build do
  alink("Home", :href=>"/")
end
```

Better yet, the `alink` method lets you easily add parameters. To do this, you have to place the args in curly brackets, then list your parameters at the end like so:

```ruby
params={:id=>77}
out =Demeler.build do
  alink("Jobs", {:href=>"jobs"}, :id=>params[:id], :job=>'commercial')
end
```

The HTML generated will look like this:

```html
<!-- begin generated output -->
<a href="jobs?id=77&job=commercial">Jobs</a>
<!-- end generated output -->
```

Name | Type | Value
---- | ---- | -----
text | String | The text to be inserted into the tag.
*args | Hash | An hash of attributes which must include the :href attribute.
*parms | Hash | An hash of parameters to be passed when the link is clicked.

### def checkbox(name, opts, values)

This is a shortcut to build `checkbox` tags. A properly formed check box is created for each value in the `values` list. If the form object has one or more values set, those boxes will be checked.

Each check box name will begin with `name` and have a number added, beginning with 1.

Name | Type | Value
---- | ---- | -----
name | Symbol | The name of the control. It will be prepended with a number.
opts | Hash | The attributes and options for the control.
values | Hash | The names and values of the check boxes.

The data value in the form object may be a String, Array or Hash. If this is a string, the values are comma separated. If this is an array, the elements are the values. If this is a hash, the values (right hand side of each pair) are the values.

### radio(name, opts, values)

This is a shortcut to build radio buttons. All the radio buttons in a set are named the same, and only vary in value. Unlike the checkbox control, the radio control only has one value at a time. The opts are applied to each radio button.

Name | Type | Value
---- | ---- | -----
name | Symbol | The name of the control.
opts | Hash | The attributes and options for the control.
values | Hash | The names and values of the radio boxes.

The data value in the form object may be a String, Array or Hash. If this is a string, the values are comma separated. If this is an array, the elements are the values. If this is a hash, the values (right hand side of each pair) are the values.

### def select(name, opts, values)

The select control is unique in that it has `select` tags surrounding a list of `option` tags. Based on the attributes (opts), you can create a pure dropdown list, or a scrolling list. See https://www.w3schools.com for more info on HTML.

Name | Type | Value
---- | ---- | -----
name | Symbol | The name of the control.
opts | Hash | The attributes and options for the control.
values | Hash | The names and values of the radio boxes.

The data value in the form object may be a String, Array or Hash. If this is a string, the values are comma separated. If this is an array, the elements are the values. If this is a hash, the values (right hand side of each pair) are the values.

### def submit(text, opts={})

The submit shortcut creates a `input` control of type 'submit'.

Name | Type | Value
---- | ---- | -----
text | String | The text displayed on the face of the button.
opts | Hash | The attributes and options for the control.

### def tag_generator(meth, args=[], &block)

You don't normally call `tag_generator` (although you can if you wish to). Tag_generator has many forms which are documented one by one below.

### def tag_generator(meth, opts, &block)

This form is used for most simple input controls.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
opts | Hash | The attributes, i.e., :class="user-class", etc.
block | Proc | The block

### def tag_generator(meth, &block)

This form is used for most simple controls which have no options specified.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
block | Proc | The block

### def tag_generator(meth, [text], &block)

This form is used for controls which consist of text between opening and closing tags.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
text | String | The string becomes the :text=>string attribute.
block | Proc | The block

### def tag_generator(meth, [name], &block)

This form is used for simple input controls which have only a name, i.e., `text(:username)`. You would use a control like this with a form object probably.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
name | Symbol | The name of the control.
block | Proc | The block

### def tag_generator(meth, [opts], &block)

This form is used for simple input controls which have only a name, i.e., `text(:username)`. You would use a control like this with a form object probably. This option is equivalent to the first option which is the same except the opts are not in an array.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
opts | Hash | The attributes, i.e., :class="user-class", etc.
block | Proc | The block

### def tag_generator(meth, [name, opts], &block)

This form is the same as the preceeding one, except the name is specified seperately for convenience.

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
name | Symbol | The name of the control.
opts | Hash | The attributes, i.e., :class="user-class", etc.
block | Proc | The block

### def tag_generator(meth, [name, text], &block)

This form is the same as the preceeding one, except the text is placed between opening and closing tages, but if the meth is 'label', a `for="text"` attribute is created; otherwise, a `name="text"`. (This is the call that implements `label` tags, obviously.)

Name | Type | Value
---- | ---- | -----
meth | Symbol | The method, i.e., the tag name: :p, :br, :input, etc.
name | Symbol | The name of the control.
text | String | The string becomes the :text=>string attribute.
block | Proc | The block

## How the form object is harvested

For Demeler to pick up data from the form object and automatically set `value` attributes, you need to have the following conditions:

* There must be a `name` attribute;
* There must be a form object given in the `build` or `new` method;
* The form object must contain the named key in the object's hash; and
* The retrieved data must not be `nil` and, if the retrieved data is a String, it must not be `empty`.

The data will create a:

* (for `textarea`) :text attribute; or
* (for all others) :value attribute.

## Outputting the HTML

There are two ways to output the HTML: formatted and compressed.

Formatted code is human readable, like this:

```html
<!-- begin generated output -->
<select name="vehicle" class="x">
 <option value="volvo">Volvo</option>
 <option value="saab">Saab</option>
 <option value="mercedes">Mercedes</option>
 <option value="audi">Audi</option>
</select>
<!-- end generated output -->
```

whereas compressed code looks like this:

```html
<select name=\"vehicle\" class=\"x\"><option value=\"volvo\">Volvo</option><option value=\"saab\">Saab</option><option value=\"mercedes\">Mercedes</option><option value=\"audi\">Audi</option></select>
```

Compressed HTML is faster to generate, and is recommended for production.

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
