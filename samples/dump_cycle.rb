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

puts dump.inspect

# => "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"owner\":{\"_class\":\"Person\",\"_id\":1,\"_instance_variables\":{\"cars\":{\"_class\":\"Array\",\"_data\":[{\"_class\":\"Car\",\"_id\":1}]},\"dob\":{\"_class\":\"Time\",\"_data\":[0,2458044,50584,0,-14400,2299161.0]},\"name\":\"Sean Hux\"}},\"year\":\"2002\"}}"
