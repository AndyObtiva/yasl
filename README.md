# YASL - Yet Another Serialization Library
[![Ruby](https://github.com/AndyObtiva/yasl/workflows/Ruby/badge.svg)](https://github.com/AndyObtiva/yasl/actions?query=workflow%3ARuby)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/yasl/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/yasl?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/e8d043b8c78c801f0aa3/maintainability)](https://codeclimate.com/github/AndyObtiva/yasl/maintainability)

A pure Ruby serialization library that works across different Ruby implementations like Opal and JRuby as an alternative to YAML/Marshal.

## Requirements

- Portablity across different Ruby implementations, especially Opal and JRuby.
- Zero configuration. Developers are too busy solving business domain problems to worry about low-level serialization details.
- Silently ignore non-serializable objects like `Proc`, `Binding`, and `IO`.
- Support serializing classes and modules, not just object instances.
- JSON encoding is good enough. No need for premature optimization.

## Usage Instructions

[GEM NOT YET PUBLISHED]

Run:

`gem install yasl`

Or add to Gemfile:

```ruby
gem 'yasl', '~> 0.1.0'
```

And, run:

`bundle`

Finally, require in Ruby code:

```ruby
require 'yasl'
```

### Serialize

To serialize, use the `YASL#dump` method.

Example (from [samples/basic.rb](samples/basic.rb)):

```ruby
require 'yasl'

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

Example (from [samples/cycle.rb](samples/cycle.rb)):

```ruby
$LOAD_PATH.unshift File.expand_path(File.join(__dir__, '..', 'lib'))

require 'yasl'

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

#### `include_classes` option

(default: `false`)

Passing `include_classes: true` to the `YASL#dump` method causes YASL to serialize classes and modules too (class variables and singleton class instance variables). They go under the `_classes` JSON array.

Example (from [samples/include_classes.rb](samples/include_classes.rb)):

```ruby
$LOAD_PATH.unshift File.expand_path(File.join(__dir__, '..', 'lib'))

require 'yasl'

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
  
  attr_accessor :name, :dob
  
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

dump = YASL.dump(car, include_classes: true)

puts dump.inspect

# => "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"owner\":{\"_class\":\"Person\",\"_id\":1,\"_instance_variables\":{\"dob\":{\"_class\":\"Time\",\"_data\":[0,2458044,50584,0,-14400,2299161.0]},\"name\":\"Sean Hux\"}},\"year\":\"2002\"},\"_classes\":[{\"_class\":\"Person\",\"_class_variables\":{\"class_count\":1},\"_instance_variables\":{\"count\":1}}]}"
```


### Deserialize

[DESERIALIZE NOT FULLY IMPLEMENTED]

To deserialize, use the `YASL#load` method.

```ruby
require 'yasl'

dump = "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"year\":\"2002\",\"registration_time\":{\"_class\":\"Time\",\"_data\":[0,2452932,49177,\"12644383719423828125/137438953472\",-10800,2299161.0]},\"registration_date\":{\"_class\":\"Date\",\"_data\":[0,2452932,0,0,0,2299161.0]},\"registration_date_time\":{\"_class\":\"DateTime\",\"_data\":[0,2452932,49177,92000000,-10800,2299161.0]},\"complex_number\":{\"_class\":\"Complex\",\"_data\":\"2+37i\"},\"complex_polar_number\":{\"_class\":\"Complex\",\"_data\":\"22.13993492521203-6.230833131080988i\"},\"rational_number\":{\"_class\":\"Rational\",\"_data\":\"3/1\"}}}"

car = YASL.load(dump)
```

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
