# YASL - Yet Another Serialization Library
[![Gem Version](https://badge.fury.io/rb/yasl.svg)](http://badge.fury.io/rb/yasl)
[![rspec](https://github.com/AndyObtiva/yasl/workflows/rspec/badge.svg)](https://github.com/AndyObtiva/yasl/actions?query=workflow%3Arspec)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/yasl/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/yasl?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/e8d043b8c78c801f0aa3/maintainability)](https://codeclimate.com/github/AndyObtiva/yasl/maintainability)

A pure Ruby serialization library that works across different Ruby implementations like [Opal](https://opalrb.com/) and [JRuby](https://www.jruby.org/) as an alternative to YAML/Marshal.

(Note: this is an early alpha gem, so please use with caution, and report any encountered issues or feature suggestions to help improve)

## Requirements

- Portablity across different Ruby implementations, especially [Opal](https://opalrb.com/) in the web browser and [JRuby](https://www.jruby.org/).
- Zero required configuration. Developers are too busy solving business domain problems to worry about low-level serialization details.
- Silently ignore non-serializable objects (unlike Marshal), such as `Proc`, `Binding`, and `IO`.
- No special performance requirements. No high throughput usage. Average Internet speeds.
- Ensure system safety through secure deserialization.
- JSON encoding is good enough. No need for premature optimization.

## Usage Instructions

Run:

`gem install yasl`

Or add to Gemfile:

```ruby
gem 'yasl', '~> 0.2.0'
```

And, run:

`bundle`

Finally, require in Ruby code:

```ruby
require 'yasl'
```

### Serialize

To serialize, use the `YASL#dump(object)` method.

Keep in mind that `YASL::UNSERIALIZABLE_DATA_TYPES` class names are unserializable, and will serialize as `nil` (feel free to add more class names that you would like filtered out):

`'Proc'`, `'Binding'`, `'IO'`, `'File::Stat'`, `'Dir'`, `'BasicSocket'`, `'MatchData'`, `'Method'`, `'UnboundMethod'`, `'Thread'`, `'ThreadGroup'`, `'Continuation'`

Example (from [samples/dump_basic.rb](samples/dump_basic.rb)):

```ruby
require 'yasl'
require 'date'

class Car
  attr_accessor :make,
                :model,
                :year,
                :registration_time,
                :registration_date,
                :registration_date_time,
                :complex_number,
                :complex_polar_number,
                :rational_number
end

car = Car.new
car.make = 'Mitsubishi'
car.model = 'Eclipse'
car.year = '2002'
car.registration_time = Time.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
car.registration_date = Date.new(2003, 10, 19)
car.registration_date_time = DateTime.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
car.complex_number = Complex(2,37)
car.complex_polar_number = Complex.polar(-23,28)
car.rational_number = Rational(22/7)

dump = YASL.dump(car)

puts dump.inspect

# => "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"year\":\"2002\",\"registration_time\":{\"_class\":\"Time\",\"_data\":[0,2452932,49177,\"12644383719423828125/137438953472\",-10800,2299161.0]},\"registration_date\":{\"_class\":\"Date\",\"_data\":[0,2452932,0,0,0,2299161.0]},\"registration_date_time\":{\"_class\":\"DateTime\",\"_data\":[0,2452932,49177,92000000,-10800,2299161.0]},\"complex_number\":{\"_class\":\"Complex\",\"_data\":\"2+37i\"},\"complex_polar_number\":{\"_class\":\"Complex\",\"_data\":\"22.13993492521203-6.230833131080988i\"},\"rational_number\":{\"_class\":\"Rational\",\"_data\":\"3/1\"}}}"
```

#### Cycles

YASL automatically detects cycles when serializing bidirectional object references.

Example (from [samples/dump_cycle.rb](samples/dump_cycle.rb)):

```ruby
require 'yasl'
require 'date'
require 'set'

class Car
  attr_accessor :make,
                :model,
                :year,
                :owner
end

class Person
  class << self
    def reset_count!
      @count = 0
    end
    
    def increment_count!
      @count ||= 0
      @count += 1
    end
    
    def reset_class_count!
      @@class_count = 0
    end
    
    def increment_class_count!
      @@class_count = 0 unless defined?(@@class_count)
      @@class_count += 1
    end
  end
  
  attr_accessor :name, :dob, :cars
  
  def initialize
    self.class.increment_count!
    self.class.increment_class_count!
  end
end

person = Person.new
person.name = 'Sean Hux'
person.dob = Time.new(2017, 10, 17, 10, 3, 4)

car = Car.new
car.make = 'Mitsubishi'
car.model = 'Eclipse'
car.year = '2002'

car.owner = person
person.cars = [car]

dump = YASL.dump(car)

puts dump.inspect

# => "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"owner\":{\"_class\":\"Person\",\"_id\":1,\"_instance_variables\":{\"cars\":{\"_class\":\"Array\",\"_data\":[{\"_class\":\"Car\",\"_id\":1}]},\"dob\":{\"_class\":\"Time\",\"_data\":[0,2458044,50584,0,-14400,2299161.0]},\"name\":\"Sean Hux\"}},\"year\":\"2002\"}}"
```

### Deserialize

To deserialize, use the `YASL#load(data, whitelist_classes: [])` method. The `whitelist_classes` array must mention all classes expected to appear in the serialized data to load. This is required to ensure software security by not allowing arbitrary unexpected classes to be deserialized.

By default, only `YASL::RUBY_BASIC_DATA_TYPES` classes are deserialized:

`NilClass`, `String`, `Integer`, `Float`, `TrueClass`, `FalseClass`, `Time`, `Date`, `Complex`, `Rational`, `Regexp`, `Symbol`, `Set`, `Range`, `Array`, `Hash`

Example (from [samples/load_basic.rb](samples/load_basic.rb)):

```ruby
require 'yasl'
require 'date'

class Car
  attr_accessor :make,
                :model,
                :year,
                :registration_time,
                :registration_date,
                :registration_date_time,
                :complex_number,
                :complex_polar_number,
                :rational_number
end

car = Car.new
car.make = 'Mitsubishi'
car.model = 'Eclipse'
car.year = '2002'
car.registration_time = Time.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
car.registration_date = Date.new(2003, 10, 19)
car.registration_date_time = DateTime.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
car.complex_number = Complex(2,37)
car.complex_polar_number = Complex.polar(-23,28)
car.rational_number = Rational(22/7)

dump = YASL.dump(car)
car2 = YASL.load(dump, whitelist_classes: [Car])

puts car2.make
# => Mitsubishi

puts car2.model
# => Eclipse

puts car2.year
# => 2002

puts car2.registration_time
# => 2003-10-19 10:39:37 -0300

puts car2.registration_date
# => 2003-10-19

puts car2.registration_date_time
# => 2003-10-19T10:39:37-03:00

puts car2.complex_number
# => 2+37i

puts car2.complex_polar_number
# => 22.13993492521203-6.230833131080988i

puts car2.rational_number
# => 3/1

```

#### Cycles

YASL automatically restores cycles when deserializing bidirectional object references.

Example (from [samples/load_cycle.rb](samples/load_cycle.rb)):

```ruby
require 'yasl'
require 'date'
require 'set'

class Car
  attr_accessor :make,
                :model,
                :year,
                :owner
end

class Person
  class << self
    def reset_count!
      @count = 0
    end
    
    def increment_count!
      @count ||= 0
      @count += 1
    end
    
    def reset_class_count!
      @@class_count = 0
    end
    
    def increment_class_count!
      @@class_count = 0 unless defined?(@@class_count)
      @@class_count += 1
    end
  end
  
  attr_accessor :name, :dob, :cars
  
  def initialize
    self.class.increment_count!
    self.class.increment_class_count!
  end
end

person = Person.new
person.name = 'Sean Hux'
person.dob = Time.new(2017, 10, 17, 10, 3, 4)

car = Car.new
car.make = 'Mitsubishi'
car.model = 'Eclipse'
car.year = '2002'

car.owner = person
person.cars = [car]

dump = YASL.dump(car)
car2 = YASL.load(dump, whitelist_classes: [Car, Person])

puts car2.make
# => Mitsubishi

puts car2.model
# => Eclipse

puts car2.year
# => 2002

puts car2.owner
# => #<Person:0x00007ffdf008dc20>

puts car2.owner.name
# => Sean Hux

puts car2.owner.dob
# => 2017-10-17 10:03:04 -0400

puts car2.owner.cars.inspect
# => [#<Car:0x00007ffdf008e120 @make="Mitsubishi", @model="Eclipse", @year="2002", @owner=#<Person:0x00007ffdf008dc20 @name="Sean Hux", @dob=2017-10-17 10:03:04 -0400, @cars=[...]>>]

puts car2.inspect
# => #<Car:0x00007ffdf008e120 @make="Mitsubishi", @model="Eclipse", @year="2002", @owner=#<Person:0x00007ffdf008dc20 @name="Sean Hux", @dob=2017-10-17 10:03:04 -0400, @cars=[#<Car:0x00007ffdf008e120 ...>]>>
```

### Struct

Struct serialization/deserialization works out of the box in standard [MRI Ruby](https://www.ruby-lang.org/) and [JRuby](https://www.jruby.org/).

To avoid some JS and `keyword_init` issues with `Struct` in [Opal](https://opalrb.com/), you may use the optional pure Ruby Struct re-implementation that comes with YASL:

```ruby
require 'yasl/ext/struct'
```

This ensures successful serialization in YASL.

## Contributing

-   Check out the latest master to make sure the feature hasn't been
    implemented or the bug hasn't been fixed yet.
-   Check out the issue tracker to make sure someone already hasn't
    requested it and/or contributed it.
-   Fork the project.
-   Start a feature/bugfix branch.
-   Commit and push until you are happy with your contribution.
-   Make sure to add tests for it. This is important so I don't break it
    in a future version unintentionally.
-   Please try not to mess with the Rakefile, version, or history. If
    you want to have your own version, or is otherwise necessary, that
    is fine, but please isolate to its own commit so I can cherry-pick
    around it.

## TODO

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Copyright

[MIT](LICENSE.txt)

Copyright (c) 2020 Andy Maleh.
