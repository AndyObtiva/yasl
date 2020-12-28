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
