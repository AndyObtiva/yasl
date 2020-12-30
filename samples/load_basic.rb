$LOAD_PATH.unshift File.expand_path(File.join(__dir__, '..', 'lib'))

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
