$LOAD_PATH.unshift File.expand_path(File.join(__dir__, '..', 'lib'))

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
