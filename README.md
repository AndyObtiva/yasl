# YASL - Yet Another Serialization Library
[![Ruby](https://github.com/AndyObtiva/yasl/workflows/Ruby/badge.svg)](https://github.com/AndyObtiva/yasl/actions?query=workflow%3ARuby)

A Ruby serialization library that serializes/deserializes objects through their instance variables and Struct members by default without complaining about unserializable objects.

## Background

There are many Ruby serialization libraries out there, but none simply serialize objects perfectly as they are and deserialize them on the other side regardless of what is stored in them. Even `Marshal` is error-prone and complains when certain conditions are not met. YASL aims to provide serialization similar to `Marshal`'s, albeit simpler and without complaining about unserializable objects. After all, 90% of the time, I don't care if a proc, binding, or singleton method got serialized or not. I just want the object containing them to get serialized successfully, and that is all I need.

## Assumptions

- Both the server and client contain the same Ruby classes
- Zero configuration. Developers are too busy solving business domain problems to worry about low-level serialization details.
- Silently ignore all that is not serializable like Proc, Binding, and IO objects
- No worry about cycles. The library handles them for us.
- JSON is good enough. No need for premature optimization.

## Usage Instructions

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

To serialize, use the `YASL#dump` method:

```ruby
class Car
  attr_accessor :make,
                :model,
                :year,
                :registration_time,
                :registration_date,
                :registration_date_time,
                :complex_number,
                :complex_polar_number,
                :rational_number,
                :owner
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

require 'yasl'

dump = YASL.dump(car)

# => "{\"_class\":\"Car\",\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"year\":\"2002\",\"registration_time\":{\"_class\":\"Time\",\"_data\":[0,2452932,49177,\"12644383719423828125/137438953472\",-10800,2299161.0]},\"registration_date\":{\"_class\":\"Date\",\"_data\":[0,2452932,0,0,0,2299161.0]},\"registration_date_time\":{\"_class\":\"DateTime\",\"_data\":[0,2452932,49177,92000000,-10800,2299161.0]},\"complex_number\":{\"_class\":\"Complex\",\"_data\":\"2+37i\"},\"complex_polar_number\":{\"_class\":\"Complex\",\"_data\":\"22.13993492521203-6.230833131080988i\"},\"rational_number\":{\"_class\":\"Rational\",\"_data\":\"3/1\"}}}"
```

### Deserialize

To deserialize, use the `YASL#load` method:

```ruby
require 'yasl'

dump = "{\"_class\":\"Car\",\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"year\":\"2002\",\"registration_time\":{\"_class\":\"Time\",\"_data\":[0,2452932,49177,\"12644383719423828125/137438953472\",-10800,2299161.0]},\"registration_date\":{\"_class\":\"Date\",\"_data\":[0,2452932,0,0,0,2299161.0]},\"registration_date_time\":{\"_class\":\"DateTime\",\"_data\":[0,2452932,49177,92000000,-10800,2299161.0]},\"complex_number\":{\"_class\":\"Complex\",\"_data\":\"2+37i\"},\"complex_polar_number\":{\"_class\":\"Complex\",\"_data\":\"22.13993492521203-6.230833131080988i\"},\"rational_number\":{\"_class\":\"Rational\",\"_data\":\"3/1\"}}}"

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
