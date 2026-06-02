<p align="center">
  <h1 align="center">🧱 μ-struct</h1>
  <p align="center"><i>Create powered Ruby structs.</i></p>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/u-struct">
    <img alt="Gem" src="https://img.shields.io/gem/v/u-struct.svg?style=flat-square">
  </a>
  <a href="https://github.com/u-gems/u-struct/actions/workflows/ci.yml">
    <img alt="Build Status" src="https://github.com/u-gems/u-struct/actions/workflows/ci.yml/badge.svg">
  </a>
  <br/>
  <a href="https://qlty.sh/gh/u-gems/projects/u-struct"><img src="https://qlty.sh/gh/u-gems/projects/u-struct/maintainability.svg" alt="Maintainability" /></a>
  <a href="https://qlty.sh/gh/u-gems/projects/u-struct"><img src="https://qlty.sh/gh/u-gems/projects/u-struct/coverage.svg" alt="Code Coverage" /></a>
  <br/>
  <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
  <img src="https://img.shields.io/badge/Rails%20%3E%3D%206.0%2C%20%3C%3D%20Edge-rails.svg?colorA=444&colorB=333" alt="Rails">
</p>

> [!IMPORTANT]
> **No breaking API changes — ever.** `u-struct`'s public API is frozen: every release stays backward-compatible, so code that builds on it keeps working.
>
> Major version bumps signal only that a Ruby or Rails version was dropped from the supported matrix — per SemVer, a dependency-floor change. Your code keeps working.
>
> **Maintenance mode.** Ruby 3.2+ ships a native [`Data`](https://docs.ruby-lang.org/en/3.2/Data.html) type that covers this gem's use case; `u-struct` is kept only to support existing apps and gets no new features. New code should prefer `Data`.

# Table of contents: <!-- omit in toc -->

- [Introduction](#introduction)
  - [Motivation](#motivation)
- [Installation](#installation)
- [Usage](#usage)
  - [`Micro::Struct.new`](#microstructnew)
    - [`optional:` option](#optional-option)
    - [`required:` option](#required-option)
    - [Defining custom methods/behavior](#defining-custom-methodsbehavior)
  - [`Micro::Struct.with`](#microstructwith)
  - [`Micro::Struct[]`](#microstruct)
    - [`:to_ary`](#to_ary)
    - [`:to_hash`](#to_hash)
    - [`:to_proc`](#to_proc)
    - [`:readonly`](#readonly)
    - [`:instance_copy`](#instance_copy)
    - [`:exposed_features`](#exposed_features)
  - [`Micro::Struct.instance` or `Micro::Struct.with(...).instance`](#microstructinstance-or-microstructwithinstance)
  - [`Micro::Struct.immutable`](#microstructimmutable)
  - [`Micro::Struct.readonly`](#microstructreadonly)
  - [TL;DR](#tldr)
- [FAQ](#faq)
  - [How to override the Struct `.new` method?](#how-to-override-the-struct-new-method)
  - [Can I override the Struct initializer?](#can-i-override-the-struct-initializer)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

## Introduction

Ruby `Struct` is a versatile data structure because it can behave like an `Array`, `Hash`, and ordinary object:

```ruby
Person = Struct.new(:first_name, :last_name)

person = Person.new('Rodrigo', 'Serradura')
# #<struct Person first_name="Rodrigo", last_name="Serradura">

# -- Ordinary object behavior --

person.first_name # "Rodrigo"
person.last_name  # "Serradura"

person.first_name = 'John' # "John"
person.last_name = 'Doe'   # "Doe"

person
# #<struct Person first_name="John", last_name="Doe">

# -- Hash behavior --

person[:first_name] # "Doe"
person['last_name'] # "John"

person[:first_name] = 'Rodrigo'   # "Rodrigo"
person['last_name'] = 'Serradura' # "Serradura"

person
# #<struct Person first_name="Rodrigo", last_name="Serradura">


# Transforming a Struct into a Hash
person.to_h
# {:first_name=>"Rodrigo", :last_name=>"Serradura"}

# -- Array behavior --

person[0] # "Rodrigo"
person[1] # "Serradura"

person[0] = 'John' # "John"
person[1] = 'Doe'  # "Doe"

person
# #<struct Person first_name="John", last_name="Doe">

# Transforming a Struct into an Array
person.to_a
# ["John", "Doe"]
```

Because of these characteristics, structs could be excellent candidates to create different kinds of POROs (Plain Old Ruby Objects). However, it is very common to see developers avoiding its usage because of some of its behaviors, like setters or the constructor's positional arguments. The addition of keywords arguments on its constructor ([available on Ruby >= 2.5](https://www.bigbinary.com/blog/ruby-2-5-allows-creating-structs-with-keyword-arguments)) improved the experience to instantiate `Struct` objects but it doesn't require all the arguments. Some developers can still feel uncomfortable with that and they might avoid its usage.

Look at the example showing the Struct's `keyword_init:` option creating a constructor with optional keyword arguments:

```ruby
Person = Struct.new(:first_name, :last_name, keyword_init: true)

Person.superclass # Struct

Person.new
# #<struct Person first_name=nil, last_name=nil>

# Because of this, you will only see an exception
# if you pass one or more invalid keywords.

Person.new(foo: 1, bar: 2)
# ArgumentError (unknown keywords: foo, bar)
```

### Motivation

So, given this introduction, the idea of this project is to provide a way of creating Ruby Structs with some [powerful features](#microstructwith). Let's see how the `Micro::Struct.new()` works.

```ruby
require 'u-struct'

Person = Micro::Struct.new(:first_name, :last_name)

Person.superclass
# Struct

Person.new
# ArgumentError (missing keywords: :first_name, :last_name)
```

As you can see, the struct instantiation raised an error because all of the keywords arguments are required.

If you need one or many optional arguments, you can use the `optional:` option to define them:

```ruby
Person = Micro::Struct.new(:first_name, optional: :last_name)

Person.new
# ArgumentError (missing keyword: :first_name)

Person.new(first_name: 'Rodrigo')
# #<struct Person first_name="Rodrigo", last_name=nil>
```

If you want a `Struct` only with optional members (or attributes), as the `keyword_init:` option does, you can declare all attributes within the optional: option:

```ruby
Person = Micro::Struct.new(optional: [:first_name, :last_name])

Person.new
# #<struct Person first_name=nil, last_name=nil>
```

You can also use the `required:` option to define required attributes.

```ruby
Person = Micro::Struct.new(
  required: [:first_name, :last_name],
  optional: [:age]
)
```

So, what did you think? If you liked it, continue the reading to understand what this gem can do for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'u-struct'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install u-struct

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Usage

### `Micro::Struct.new`

Like `Struct.new`, you will use `Micro::Struct.new` to create your `Struct` classes.

The key difference is: the `Struct` created from `Micro::Struct` will use keyword arguments in their constructors.

```ruby
Person = Struct.new(:name)          # Person
Persona = Micro::Struct.new(:name)  # Persona

Person.ancestors  # [Person, Struct, Enumerable, Object, Kernel, BasicObject]
Persona.ancestors # [Person, Struct, Enumerable, Object, Kernel, BasicObject]

Person.new('Rodrigo')        # #<struct Person name="Rodrigo">
Persona.new(name: 'Rodrigo') # #<struct Person name="Rodrigo">

Person.new  # #<struct Person name=nil>

Persona.new # ArgumentError (missing keyword: :name)
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `optional:` option

If you need optional attributes, you can use this to define them.

```ruby
Person = Micro::Struct.new(:name, optional: :age)

Person.new
# ArgumentError (missing keyword: :name)

Person.new(name: 'John')
# #<struct Person name="John", age=nil>
```

Use an array to define multiple optional attributes.

```ruby
Person = Micro::Struct.new(:name, optional: [:age, :nickname])

Person.new
# ArgumentError (missing keyword: :name)

Person.new(name: 'John')
# #<struct Person name="John", age=nil, nickname=nil>
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `required:` option

It is an alternative way to define required attributes. Use a symbol to define one or an array to define multiple attributes.

```ruby
Person = Micro::Struct.new(
  required: [:first_name, :last_name],
  optional: [:age]
)

Person.new
# ArgumentError (missing keywords: :first_name, :last_name)

Person.new first_name: 'John', last_name: 'Doe'
# #<struct Person first_name="John", last_name="Doe", age=nil>
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### Defining custom methods/behavior

The `Micro::Struct.new` accepts a block as a regular `Struct`, and you can use it to define some custom behavior/methods.

```ruby
Person = Micro::Struct.new(:first_name, :last_name, optional: :age) do
  def name
    "#{first_name} #{last_name}"
  end
end

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')
# #<struct Person first_name="Rodrigo", last_name="Serradura", age=nil>

person.first_name # "Rodrigo"
person.last_name  # "Serradura"
person.name       # "Rodrigo Serradura"
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### `Micro::Struct.with`

This method can do two things: first, it can create `Struct` factories; second, it sets some special behavior to their structs.

These are all of the available features which you can use (pick one, many, or all of them):

- [`:to_ary`](#to_ary)
- [`:to_hash`](#to_hash)
- [`:to_proc`](#to_proc)
- [`:readonly`](#readonly)
- [`:instance_copy`](#instance_copy)
- [`:exposed_features`](#exposed_features)

Look at an example of defining a `Struct` factory that can create "immutable" structs by picking the `:readonly`, `:instance_copy` features.

```ruby
ReadonlyStruct = Micro::Struct.with(:readonly, :instance_copy)

# Use the factory to create structs with the same characteristics:

Person = ReadonlyStruct.new(:first_name, :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Rodrigues')
# #<struct Person first_name="Rodrigo", last_name="Rodrigues">

# The `:readonly` sets all the Struct writers as private.

person.last_name = ''
# NoMethodError (private method `last_name=' called for #<struct Person ...>)

person[:last_name] = ''
# NoMethodError (private method `[]=' called for #<struct Person ...>)

# The `:instance_copy` defines a `#with` instance method,
# which allows you to create a new instance from the current struct state.

new_person = person.with(last_name: 'Serradura')
# #<struct Person first_name="Rodrigo", last_name="Serradura">

new_person == person
# false

new_person.class == person.class
# true
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### `Micro::Struct[]`

The `[]` brackets method is as an alias of `Micro::Struct.with`. e.g.

```ruby
Micro::Struct[:readonly, :to_hash] # is the same as Micro::Struct.with(:readonly, :to_hash)
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:to_ary`

Defines a `#to_ary` method which will invoke the struct `#to_a` method. If you override the `#to_a` method you will also affect it.

The `#to_ary` makes Ruby know how to deconstruct an object like an array.

```ruby
Person = Micro::Struct.with(:to_ary).new(:first_name, :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')

first_name, last_name = person

p first_name # "Rodrigo"
p last_name  # "Serradura"

*first_and_last_name = person

p first_and_last_name # ["Rodrigo", "Serradura"]
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:to_hash`

Defines a `#to_hash` method which will invoke the struct `#to_h` method. If you override the `#to_h` method you will also affect it.

The `#to_hash` makes Ruby know how to deconstruct an object like a hash.

```ruby
Person = Micro::Struct.with(:to_hash).new(:first_name, :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')

def greet(first_name:, last_name:)
  puts "Hi #{first_name} #{last_name}!"
end

greet(**person)
# Hi Rodrigo Serradura!
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:to_proc`

The `#to_proc` tells Ruby how to invoke it as a block replacement (by using `&`).

The lambda returned from the `#to_proc` will require a hash as its argument.

```ruby
Person = Micro::Struct.with(:to_proc).new(:first_name, :last_name)

[
  {first_name: 'John', last_name: 'Doe'},
  {first_name: 'Mary', last_name: 'Doe'}
].map(&Person)
# [
#  #<struct Person::Struct first_name="John", last_name="Doe">,
#  #<struct Person::Struct first_name="Mary", last_name="Doe">
# ]
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:readonly`

This feature sets the Struct members' writers as private.

```ruby
Person = Micro::Struct.with(:readonly).new(:first_name, :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Rodrigues')
# #<struct Person first_name="Rodrigo", last_name="Rodrigues">

person.last_name = ''
# NoMethodError (private method `last_name=' called for #<struct Person ...>)

person[:last_name] = ''
# NoMethodError (private method `[]=' called for #<struct Person ...>)
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:instance_copy`

Creates the `#with` method, which will instantiate a struct of the same kind and reuse its current state.

```ruby
Person = Micro::Struct.with(:instance_copy).new(:first_name, :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')
# => #<struct Person::Struct first_name="Rodrigo", last_name="Serradura">

person.first_name = 'John'
# => "John"

person.inspect
# => #<struct Person::Struct first_name="John", last_name="Serradura">

new_person = person.with(last_name: 'Doe')
# => #<struct Person::Struct first_name="John", last_name="Doe">

person === new_person     # => false
person.equal?(new_person) # => false

person.last_name     # => "Serradura"
new_person.last_name # => "Doe"
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

#### `:exposed_features`

This feature exposes the struct's configured features. Via the methods: `.features` and `.__features__`.

```ruby
Person = Micro::Struct.with(:exposed_features, :readonly, :to_proc).new(:name)

Person.features
# => #<struct Micro::Struct::Features::Exposed
#      names=[:readonly, :to_proc],
#      options={:to_ary=>false, :to_hash=>false, :to_proc=>true, :readonly=>true, :instance_copy=>false}>

Person.__features__.equal?(Person.features) # `.__features__` is an alias of `.features` method

Person.features.names   # => [:readonly, :to_proc]
Person.features.options # => {:to_ary=>false, :to_hash=>false, :to_proc=>true, :readonly=>true, :instance_copy=>false}

Person.features.option?(:to_proc)  # => true
Person.features.option?(:readonly) # => true

Person.features.options?(:to_proc)  # => true
Person.features.options?(:readonly) # => true

Person.features.options?(:to_proc, :readonly) # => true
Person.features.options?(:to_ary, :readonly)  # => false
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### `Micro::Struct.instance` or `Micro::Struct.with(...).instance`

Creates a struct instance from a given hash. This could be useful to create constants or a singleton value.

```ruby
person1 = Micro::Struct.instance(first_name: 'Rodrigo', last_name: 'Serradura')
# => #<struct  first_name="Rodrigo", last_name="Serradura">

person1.first_name = 'John'

person1.first_name # => "John"
```

You can also use the instance method after defining some struct feature ([`Micro::Struct.with`](#microstructwith)).

```ruby
person2 = Micro::Struct.with(:readonly).instance(first_name: 'Rodrigo', last_name: 'Serradura')
# => #<struct  first_name="Rodrigo", last_name="Serradura">

person2.first_name = 'John'
# NoMethodError (private method `first_name=' called for #<struct first_name="Rodrigo", last_name="Serradura">)
```

And if you need some custom behavior, use a block to define them.

```ruby
person3 = Micro::Struct.instance(first_name: 'Rodrigo', last_name: 'Serradura') do
  def name
    "#{first_name} #{last_name}"
  end
end

person4 = Micro::Struct.with(:readonly).instance(first_name: 'Rodrigo', last_name: 'Serradura') do
  def name
    "#{first_name} #{last_name}"
  end
end

person3.name # => "Rodrigo Serradura"
person4.name # => "Rodrigo Serradura"
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### `Micro::Struct.immutable`

This method is as a shortcut to `Micro::Struct.with(:readonly, :instance_copy)`.
As it is quite common to see the usage of these two features, I decided to create this method to improve the DX.

Additional info:

1. It accepts the `with:` option, which can be used to define additional features.
2. The `.instance` method can be called after its usage.

Usage examples:

```ruby
Micro::Struct.immutable.new(:name)

Micro::Struct.immutable.new(:name) do
  def hi(other_name)
    "Hi, #{other_name}! My name is #{name}"
  end
end

Micro::Struct.immutable(with: :to_hash).new(:name)

Micro::Struct.immutable(with: [:to_hash, :to_proc]).new(:name)

Micro::Struct.immutable.instance(name: 'Rodrigo')

Micro::Struct.immutable(with: [:to_hash]).instance(name: 'Serradura')
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### `Micro::Struct.readonly`

This method is as a shortcut to `Micro::Struct.with(:readonly)`.

Additional info:

1. It accepts the `with:` option, which can be used to define additional features.
2. The `.instance` method can be called after its usage.

Usage examples:

```ruby
Micro::Struct.readonly.new(:name)

Micro::Struct.readonly.new(:name) do
  def hi(other_name)
    "Hi, #{other_name}! My name is #{name}"
  end
end

Micro::Struct.readonly(with: :to_hash).new(:name)

Micro::Struct.readonly(with: [:to_hash, :to_proc]).new(:name)

Micro::Struct.readonly.instance(name: 'Rodrigo')

Micro::Struct.readonly(with: [:to_hash]).instance(name: 'Serradura')
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### TL;DR

Like in a regular `Struct`, you can define one or many attributes but all of them will be required by default.

```ruby
Micro::Struct.new(:first_name, :last_name, ...)
```

Use the `optional:` argument if you want some optional attributes.

```ruby
Micro::Struct.new(:first_name, :last_name, optional: :gender)

# Using `optional:` to define all attributes are optional.

Micro::Struct.new(optional: [:first_name, :last_name])
```

Use the `required:` argument to define required attributes.

```ruby
Micro::Struct.new(
  required: [:first_name, :last_name],
  optional: [:gender, :age]
)
```

You can also pass a block to define custom methods.

```ruby
Micro::Struct.new(:name) {}
```

Available features (use one, many, or all) to create Structs with a special behavior:

```ruby
Micro::Struct.with(:to_ary)
Micro::Struct.with(:to_ary, :to_hash)
Micro::Struct.with(:to_ary, :to_hash, :to_proc)
Micro::Struct.with(:to_ary, :to_hash, :to_proc, :readonly)
Micro::Struct.with(:to_ary, :to_hash, :to_proc, :readonly, :instance_copy)
Micro::Struct.with(:to_ary, :to_hash, :to_proc, :readonly, :instance_copy, :exposed_features)
```

All of the possible combinations to create a Ruby Struct using `Micro::Struct`:

```ruby
Micro::Struct.new(*required)
Micro::Struct.new(*required) {}

Micro::Struct.new(optional: *)
Micro::Struct.new(optional: *) {}

Micro::Struct.new(required: *)
Micro::Struct.new(required: *) {}

Micro::Struct.new(*required, optional: *)
Micro::Struct.new(*required, optional: *) {}

Micro::Struct.new(required: *, optional: *)
Micro::Struct.new(required: *, optional: *) {}
```

Any options above can be used by the `.new()` method of the struct creator returned by the `.with()` method.

```ruby
Micro::Struct.with(*features).new(...) {}
```

Use `Micro::Struct.instance()` or `Micro::Struct.with(...).instance()` to create a struct instance from a given hash.

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## FAQ

### How to override the Struct `.new` method?

The `.new` is an alias for the `.__new__` method, so you can use `.__new__` when overriding it.

```ruby
module RGB
  Number = ->(value) do
    return value if value.is_a?(::Integer) && value >= 0 && value <= 255

    raise TypeError, "#{value} must be an Integer(>= 0 and <= 255)"
  end

  Color = Micro::Struct.new(:red, :green, :blue) do
    def self.new(r, g, b)
      __new__(
        red: Number[r],
        green: Number[g],
        blue: Number[b],
      )
    end

    def to_hex
      "##{red}#{green}#{blue}"
    end
  end
end

rgb_color = RGB::Color.new(1, 5, 255)
# => #<struct RGB::Color::Struct red=#<struct RGB::Number value=1>, green=#<struct RGB::Number value=5>, blue=#<struct RGB::Number value=255>>

rgb_color.to_hex
# => "#0105ff"

RGB::Color.new(-1, 5, 255)
# => TypeError: -1 must be an Integer(>= 0 and <= 255)
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

### Can I override the Struct initializer?

Yes, you can, but the initializer must handle the arguments as positional ones.

```ruby
RGBColor = Micro::Struct.with(:readonly, :to_ary).new(:red, :green, :blue) do
  Number = ->(value) do
    return value if value.is_a?(::Integer) && value >= 0 && value <= 255

    raise TypeError, "#{value} must be an Integer(>= 0 and <= 255)"
  end

  def initialize(r, g, b)
    super(Number[r], Number[g], Number[b])
  end

  def to_hex
    '#%02x%02x%02x' % self
  end
end

rgb_color = RGBColor.new(red: 1, green: 1, blue: 255)
# #<struct RGBColor red=1, green=1, blue=255>

r, g, b = rgb_color

[r,g,b]
# [1, 1, 255]

rgb_color.to_hex
# "#0101ff"

RGBColor.new(red: 1, green: -1, blue: 255)
# TypeError (-1 must be an Integer(>= 0 and <= 255))
```

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Additional tools:

- Sorbet (type checker): `bundle exec srb tc` (requires `Ruby >= 2.7`).
- Rubocop (linter and code formatter): `bundle rubocop` (requires `Ruby >= 2.5`).

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/u-gems/u-struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/u-gems/u-struct/blob/main/CODE_OF_CONDUCT.md).

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Code of Conduct

Everyone interacting in the `Micro::Struct` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/u-gems/u-struct/blob/main/CODE_OF_CONDUCT.md).

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Contact

Rodrigo Serradura - [Twitter](https://twitter.com/serradura) | [LinkedIn](https://www.linkedin.com/in/rodrigo-serradura/).

<p align="right">(<a href="#table-of-contents-">⬆️ &nbsp;back to top</a>)</p>

## Acknowledgments

- [`@vitoravelino`](https://github.com/vitoravelino) thanks for talking about some gem's ideas and reviewing the documentation.
