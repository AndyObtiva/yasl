$LOAD_PATH.unshift File.expand_path(File.join(__dir__, '..', 'lib'))

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
