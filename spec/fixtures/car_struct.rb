CAR_STRUCT_ATTRIBUTES = [
  :make,
  :model,
  :year,
  :registration_time,
  :registration_date,
  :registration_date_time,
  :big_decimal_number,
  :complex_number,
  :complex_polar_number,
  :rational_number,
  :regex,
  :symbol,
  :set,
  :range,
  :range_exclusive,
]
class CarStruct < Struct.new(
                    *CAR_STRUCT_ATTRIBUTES,
                    keyword_init: true
                  )
  attr_accessor :owner
  
  include Equalizer.new(*CAR_STRUCT_ATTRIBUTES + [:owner])
  
end
