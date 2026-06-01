# Changelog <!-- omit in toc -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Bump the minimum supported Ruby to `>= 2.7.0` (was `>= 2.2.0`).
- Modernize the CI: test against Ruby 2.7 → 4.0 + head and, via Appraisal,
  against ActiveModel 6.0 → 8.1 + edge (Rails `>= 6.0`).

## [1.1.0] - 2022-03-23

### Added

- Add `Micro::Struct[]` as an alias of `Micro::Struct.with`.

  ```ruby
  Micro::Struct[:readonly] # is the same as Micro::Struct.with(:readonly)
  ```

- Add `Micro::Struct.immutable` method as a shortcut to `Micro::Struct.with(:readonly, :instance_copy)`.
  It also accepts the `with:` option, which can be used to define additional features.

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

- Add `Micro::Struct.readonly` method as a shortcut to `Micro::Struct.with(:readonly)`.
  It has the same properties of `Micro::Struct.immutable`.

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

  **Development stuff**

- Set up Rubocop.
- Add `.rbi` files, and set up sorbet to be used in development.

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [1.0.0] - 2022-01-20

- Review and update docs and examples. ;)

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.12.0] - 2021-12-22

### Added

- Add `Micro::Struct.instance` to create a struct instance from a given hash.
  This could be useful to create constants or a singleton value.

  ```ruby
  person1 = Micro::Struct.instance(first_name: 'Rodrigo', last_name: 'Serradura')
  # => #<struct  first_name="Rodrigo", last_name="Serradura">

  person1.first_name = 'John'

  person1.first_name # => "John"
  ```

  You can use the instance method after defining some struct feature.

  ```ruby
  person2 = Micro::Struct.with(:readonly).instance(first_name: 'Rodrigo', last_name: 'Serradura')
  # => #<struct  first_name="Rodrigo", last_name="Serradura">

  person2.first_name = 'John'
  # NoMethodError (private method `first_name=' called for #<struct first_name="Rodrigo", last_name="Serradura">)
  ```

  You can use pass a block to define some custom behavior to the struct instance.

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

- Add `Micro::Struct.with(:exposed_features)` to expose the struct's configured features.
  Via the methods: `.features` and `.__features__`.

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

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.11.0] - 2021-12-19

### Added

- Reduce the required Ruby version to `>= 2.2.0`.
- Set up a CI with Github actions.
- Test the codebase against the Ruby versions: `2.2`, `2.3`, `2.4`, `2.5`, `2.6`, `2.7`, `3.0` and `3.1.0-preview1`.

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.10.0] - 2021-12-15

### Changed

- Make `Micro::Struct.new` return a Ruby struct instead of a module.

```ruby
module RGB
  Number = ::Struct.new(:value) { def to_s; '%02x' % value; end }

  Color = Micro::Struct.new(:red, :green, :blue) do
    def self.new(r, g, b)
      __new__(
        red: Number.new(r),
        green: Number.new(g),
        blue: Number.new(b),
      )
    end

    def to_hex
      "##{red}#{green}#{blue}"
    end
  end
end

rgb_color = RGB::Color.new(1,5,255)
# => #<struct RGB::Color red=#<struct RGB::Number value=1>, green=#<struct RGB::Number value=5>, blue=#<struct RGB::Number value=255>>

rgb_color.to_hex
# => "#0105ff"
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.9.0] - 2021-12-14

### Added

- Add `__new__` method and make `.new` its alias. You can use `__new__` when overwriting the module's `new`.

```ruby
module RGB
  Number = ::Struct.new(:value) { def to_s; '%02x' % value; end }

  Color = Micro::Struct.new(:red, :green, :blue) do
    def to_hex
      "##{red}#{green}#{blue}"
    end
  end

  module Color
    def self.new(r, g, b)
      __new__(
        red: Number.new(r),
        green: Number.new(g),
        blue: Number.new(b),
      )
    end
  end
end

rgb_color = RGB::Color.new(1,5,255)
# => #<struct RGB::Color::Struct red=#<struct RGB::Number value=1>, green=#<struct RGB::Number value=5>, blue=#<struct RGB::Number value=255>>

rgb_color.to_hex
# => "#0105ff"
```

### Changed

- Change `:readonly` feature, now it doesn't require the `:instance_copy` by default.
  So, If you want both features, you will need to declare them together.

```ruby
Person = Micro::Struct.with(:readonly).new(:name)
Persona = Micro::Struct.with(:readonly, :instance_copy).new(:name)

person = Person.new(name: 'Rodrigo')
persona = Persona.new(name: 'Serradura')

person.respond_to?(:name=)  # false
persona.respond_to?(:name=) # false

person.respond_to?(:with)  # false
persona.respond_to?(:with) # true
```

- Change `:to_ary` to invoke the `#to_a` method instead of defining it as an alias.
- Change `:to_hash` to invoke the `#to_h` method instead of defining it as an alias.

```ruby
module RGB
  Number = ::Struct.new(:value) { def to_s; '%02x' % value; end }

  Color = Micro::Struct.with(:readonly, :to_ary, :to_hash).new(:red, :green, :blue) do
    def initialize(r, g, b)
      super(Number.new(r), Number.new(g), Number.new(b))
    end

    def to_hex
      "##{red}#{green}#{blue}"
    end

    def to_a
      [red, green, blue].map(&:value)
    end

    def to_h
      { r: red.value, g: green.value, b: blue.value }
    end
  end
end

rgb_color = RGB::Color.new(red: 1, green: 5, blue: 255)
#  => #<struct RGB::Color::Struct red=#<struct RGB::Number value=1>, green=#<struct RGB::Number value=5>, blue=#<struct RGB::Number value=255>>

rgb_color.to_hex  # => "#0105ff"
rgb_color.to_ary  # => [1, 5, 255]
rgb_color.to_hash # => {:r=>1, :g=>5, :b=>255}
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.8.0] - 2021-12-05

### Added

- Add `.===` to the module, it delegates the calling to its struct.

```ruby
Person = Micro::Struct.new(:name)

person = Person.new(name: 'Rodrigo Serradura')
# => #<struct Person::Struct name="Rodrigo Serradura">

Person === person
# => true
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.7.0] - 2021-12-04

### Added

- Add `required:` option to define required struct members.

```ruby
# All of the alternatives have the same equivalence.

Person = Micro::Struct.new(:first_name, :last_name)

Person = Micro::Struct.new(required: [:first_name, :last_name])

Person = Micro::Struct.new(:first_name, required: :last_name)
```

### Changed

- Remove the `_` from the `optional:` option.

```ruby
Person = Micro::Struct.new(
  required: [:first_name, :last_name],
  optional: :age
)
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.6.0] - 2021-12-03

### Added

- Add the capability to create a struct with optional members.

```ruby
Person = Micro::Struct.new(:first_name, _optional: :last_name)

Person.new
# ArgumentError (missing keyword: :first_name)

Person.new(first_name: 'Rodrigo')
# => #<struct Person::Struct first_name="Rodrigo", last_name=nil>

# --

Persona = Micro::Struct.new(_optional: [:first_name, :last_name])

Persona.new
# => #<struct Persona::Struct first_name=nil, last_name=nil>
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.5.0] - 2021-12-02

### Added

- Add new feature `:instance_copy`. It instantiates a struct of the same kind from its current state.

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

- Add new feature `:readonly`. It sets members' writers private and requires the `:instance_copy` feature.

```ruby
Person = Micro::Struct.with(:readonly).new(:name)

person = Person.new(name: 'Rodrigo Serradura')
# => #<struct Person::Struct name="Rodrigo Serradura">

person.name = 'John Doe'
# NoMethodError (private method `name=' called for #<struct Person::Struct name="Rodrigo Serradura">)

new_person = person.with(name: 'John Doe')
# => #<struct Person::Struct name="John Doe">

person === new_person     # => false
person.equal?(new_person) # => false

person.name     # => "Rodrigo Serradura"
new_person.name # => "John Doe"
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.4.0] - 2021-12-02

### Added

- Add `.members` to the module, it delegates the calling to its struct.

```ruby
Person = Micro::Struct.new(:first_name, :last_name)

Person.members # => [:first_name, :last_name]
```

- Add `Micro::Struct.with()` to enable or disable the creation of structs with custom features.
  So now, you can create the structs with one, some, or all features. They are: `to_ary`, `to_hash`, `to_proc`.

```ruby
Person = Micro::Struct.with(:to_ary).new(:name)

person = Person.new(name: 'Rodrigo')
# => #<struct Person::Struct name="Rodrigo">

person.respond_to?(:to_ary)  # => true
person.respond_to?(:to_hash) # => false

Person.respond_to?(:to_proc) # => false
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.3.1] - 2021-12-02

### Fixed

- Fix the spec.files config of `u-struct.gemspec`.

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.3.0] - 2021-12-02

### Added

- Add `lib/u-struct.rb` to allow the bundler to require the gem in an automatic way.

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.2.0] - 2021-12-02

### Added

- Add `to_hash` as an alias of Struct's `to_h`.

```ruby
Person = Micro::Struct.new(:first_name, :last_name)

def print_first_and_last_name(first_name:, last_name:)
  puts "#{first_name} #{last_name}"
end

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')

print_first_and_last_name(**person) # Rodrigo Serradura
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

## [0.1.0] - 2021-12-02

### Added

- Create a module containing a Ruby struct with some custom features.
  - The module's `.new` method receives the struct arguments as keyword arguments.
  - The module's `.new` can receive a block as a regular `Struct` to add some custom behavior.
  - The module's `to_proc` can instantiate the struct by receiving a hash.
  - The module's struct has its initializer set up as private.
  - Add `to_ary` as an alias of module's struct `to_a`.

```ruby
Person = Micro::Struct.new(:first_name, :last_name) do
  def name
    "#{first_name} #{last_name}"
  end
end

# == Module's .new ==

Person.new
# ArgumentError (missing keywords: :first_name, :last_name)

Person.new(first_name: 'Rodrigo')
# ArgumentError (missing keyword: :last_name)

person = Person.new(first_name: 'Rodrigo', last_name: 'Serradura')
# => #<struct Person::Struct first_name="Rodrigo", last_name="Serradura">

# == Struct's block - it sets up custom behavior ==

person.name # => "Rodrigo Serradura"

# == Struct's #to_ary ==

first_name, last_name = person

p first_name # => "Rodrigo"
p last_name  # => "Serradura"

*first_and_last_name = person

p first_and_last_name # => ["Rodrigo", "Serradura"]

# == Module's .to_proc ==

[
  {first_name: 'John', last_name: 'Doe'},
  {first_name: 'Mary', last_name: 'Doe'}
].map(&Person)
# => [
#  #<struct Person::Struct first_name="John", last_name="Doe">,
#  #<struct Person::Struct first_name="Mary", last_name="Doe">
# ]

# == Struct's private initializer ==

Person::Struct.new
# => NoMethodError (private method `new' called for Person::Struct:Class)
```

<p align="right">(<a href="#changelog-">⬆️ &nbsp;back to top</a>)</p>

[Unreleased]: https://github.com/serradura/u-struct/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/serradura/u-struct/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/serradura/u-struct/compare/v0.12.0...v1.0.0
[0.12.0]: https://github.com/serradura/u-struct/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/serradura/u-struct/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/serradura/u-struct/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/serradura/u-struct/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/serradura/u-struct/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/serradura/u-struct/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/serradura/u-struct/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/serradura/u-struct/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/serradura/u-struct/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/serradura/u-struct/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/serradura/u-struct/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/serradura/u-struct/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/serradura/u-struct/releases/tag/v0.1.0
