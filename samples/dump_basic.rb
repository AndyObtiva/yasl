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

puts dump.inspect

# => "{\"_class\":\"Car\",\"_id\":1,\"_instance_variables\":{\"make\":\"Mitsubishi\",\"model\":\"Eclipse\",\"year\":\"2002\",\"registration_time\":{\"_class\":\"Time\",\"_data\":[0,2452932,49177,\"12644383719423828125/137438953472\",-10800,2299161.0]},\"registration_date\":{\"_class\":\"Date\",\"_data\":[0,2452932,0,0,0,2299161.0]},\"registration_date_time\":{\"_class\":\"DateTime\",\"_data\":[0,2452932,49177,92000000,-10800,2299161.0]},\"complex_number\":{\"_class\":\"Complex\",\"_data\":\"2+37i\"},\"complex_polar_number\":{\"_class\":\"Complex\",\"_data\":\"22.13993492521203-6.230833131080988i\"},\"rational_number\":{\"_class\":\"Rational\",\"_data\":\"3/1\"}}}"
