class CarStruct < Struct.new(
                    :make,
                    :model,
                    :year,
                    :registration_time,
                    :registration_date,
                    :registration_date_time,
                    :complex_number,
                    :complex_polar_number,
                    :rational_number,
                    :regex,
                    :symbol,
                    :set,
                    :range,
                    :range_exclusive,
                    keyword_init: true
                  )
  attr_accessor :owner
end
