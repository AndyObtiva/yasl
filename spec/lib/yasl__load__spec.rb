require 'spec_helper'

RSpec.describe do
  let(:car1) {
    Car.new.tap do |car|
      car.make = 'Mitsubishi'
      car.model = 'Eclipse'
      car.year = '2002'
      car.registration_time = Time.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
      car.registration_date = Date.new(2003, 10, 19)
      car.registration_date_time = DateTime.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
      car.complex_number = Complex(2,37)
      car.complex_polar_number = Complex.polar(-23,28)
      car.rational_number = Rational(22/7)
      car.regex = Regexp.new(/^[a-z][1-9]$/.to_s)
      car.symbol = :good
      car.set = Set.new([1, :b, 3.7])
      car.range = (1..7)
      car.range_exclusive = (1...7)
      car.class_attribute = Car
      car.module_attribute = Driving
    end
  }
  
  let(:car2) {
    Car.new.tap do |car|
      car.make = 'Toyota'
      car.model = 'Camry'
      car.year = '2001'
      car.owner = person1
    end
  }
  
  let(:car3) {
    Car.new.tap do |car|
      car.make = 'Nissan'
      car.model = 'Murano'
      car.year = '2002'
    end
  }
  
  let(:car4) {
    Car.new.tap do |car|
      car.make = 'Honda'
      car.model = 'Accord'
      car.year = '2000'
    end
  }
  
  let(:car_struct1) {
    CarStruct.new.tap do |car|
      car.make = 'Mitsubishi'
      car.model = 'Eclipse'
      car.year = '2002'
      car.registration_time = Time.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
      car.registration_date = Date.new(2003, 10, 19)
      car.registration_date_time = DateTime.new(2003, 10, 19, 10, 39, 37.092, '-03:00')
      car.complex_number = Complex(2,37)
      car.complex_polar_number = Complex.polar(-23,28)
      car.rational_number = Rational(22/7)
      car.regex = Regexp.new(/^[a-z][1-9]$/.to_s)
      car.symbol = :good
      car.set = Set.new([1, :b, 3.7])
      car.range = (1..7)
      car.range_exclusive = (1...7)
    end
  }
  
  let(:car_struct2) {
    CarStruct.new.tap do |car|
      car.make = 'Mitsubishi'
      car.model = 'Eclipse'
      car.year = '2002'
      car.owner = person1
    end
  }
  
  let(:person1) {
    Driving::Person.new.tap do |person|
      person.name = 'Sean Tux'
      person.dob = Time.new(2000, 11, 28)
    end
  }
  
  let(:person2) {
    Driving::Person.new.tap do |person|
      person.name = 'Scruff McGruff'
      person.dob = Time.new(2000, 11, 28)
      person.cars = [
        car3,
        car4,
      ]
    end
  }
  
  let(:person3) {
    Driving::Person.new.tap do |person|
      person.name = 'Linda Biggins'
      person.dob = Time.new(2000, 11, 28)
      person.cars = {
        'car1' => car3,
        'car2' => car4,
      }
    end
  }
  
  let(:person4) {
    Driving::Person.new.tap do |person|
      person.name = 'Joan Cars'
      person.dob = Time.new(2000, 11, 28)
      person.cars = [
        car3.tap {|c| c.owner = person},
        car4.tap {|c| c.owner = person},
      ]
    end
  }
  
  before do
    Car.reset_class_count!
    Car.reset_count!
    Driving::Person.reset_class_count!
    Driving::Person.reset_count!
    Driving.reset_var!
  end
  
  describe '#load' do
    context 'JSON Basic Data Types' do
      it 'deserializes Integer JSON basic data type' do
        object = YASL.load(JSON.dump(3))
        
        expect(object).to eq(3)
      end
      
      it 'deserializes Float JSON basic data type' do
        object = YASL.load(JSON.dump(3.14))
        
        expect(object).to eq(3.14)
      end
      
      it 'deserializes String JSON basic data type' do
        object = YASL.load(JSON.dump('Sean'))
        
        expect(object).to eq('Sean')
      end
      
      it 'deserializes Boolean JSON basic data type' do
        object = YASL.load(JSON.dump(true))
        
        expect(object).to eq(true)

        object = YASL.load(JSON.dump(false))
        
        expect(object).to eq(false)
      end
      
      it 'deserializes Nil JSON basic data type' do
        object = YASL.load(JSON.dump(nil))
        
        expect(object).to eq(nil)
      end
      
      it 'deserializes Array Ruby basic data type' do
        array = ['a', 2, 44.4]
        object = YASL.load(JSON.dump(
          _class: 'Array',
          _data: array
        ))
        
        expect(object).to eq(array)
      end
      
      it 'deserializes Hash Ruby basic data type' do
        hash = {key1: 'value1', key2: 'value2'}
        object = YASL.load(JSON.dump(
          _class: 'Hash',
          _data: [
            [
              {
                _class: 'Symbol',
                _data: 'key1',
              },
              'value1',
            ],
            [
              {
                _class: 'Symbol',
                _data: 'key2',
              },
              'value2',
            ],
          ]
        ))
        
        expect(object).to eq(hash)
      end
    end
    
    context 'Ruby objects and basic data types' do
      it 'deserializes instance variables of all Ruby basic data types' do
        car1
        car2
        car3
        
        data = JSON.dump(
          _class: car1.class.name,
          _id: 1,
          _instance_variables: {
            make: car1.make,
            model: car1.model,
            year: car1.year,
            registration_time: {
              _class: 'Time',
              _data: car1.registration_time.to_datetime.marshal_dump
            },
            registration_date: {
              _class: 'Date',
              _data: car1.registration_date.marshal_dump
            },
            registration_date_time: {
              _class: 'DateTime',
              _data: car1.registration_date_time.marshal_dump
            },
            complex_number: {
              _class: 'Complex',
              _data: car1.complex_number.to_s
            },
            complex_polar_number: {
              _class: 'Complex',
              _data: car1.complex_polar_number.to_s
            },
            rational_number: {
              _class: 'Rational',
              _data: car1.rational_number.to_s
            },
            regex: {
              _class: 'Regexp',
              _data: car1.regex.to_s
            },
            symbol: {
              _class: 'Symbol',
              _data: car1.symbol.to_s
            },
            set: {
              _class: 'Set',
              _data: [
                1,
                {
                  :_class => "Symbol",
                  :_data => "b"
                },
                3.7
              ]
            },
            range: {
              _class: 'Range',
              _data: [car1.range.begin, car1.range.end, car1.range.exclude_end?]
            },
            range_exclusive: {
              _class: 'Range',
              _data: [car1.range_exclusive.begin, car1.range_exclusive.end, car1.range_exclusive.exclude_end?]
            },
            class_attribute: {
              _class: 'Car',
            },
            module_attribute: {
              _class: 'Driving',
            },
          },
          _classes: [
            {
              _class: car2.class.name,
              _class_variables: {
                class_count: 1,
              },
              _instance_variables: {
                count: 1,
              },
            },
          ],
        )
        object = YASL.load(data)
        
        expect(object).to eq(car1)
        expect(Car.count).to_not eq(1)
        expect(Car.class_count).to_not eq(1)
        
        object = YASL.load(data, include_classes: true)
        
        expect(object).to eq(car1)
        expect(Car.count).to eq(1)
        expect(Car.class_count).to eq(1)
      end
      
      it 'recursively deserializes instance variables that are not basic data types' do
        car1
        car2
        car3
        person1
        person2
        
        data = JSON.dump(
          _class: car2.class.name,
          _id: 1,
          _instance_variables: {
            make: car2.make,
            model: car2.model,
            owner: {
              _class: 'Driving::Person',
              _id: 1,
              _instance_variables: {
                dob: {
                  _class: 'Time',
                  _data: person1.dob.to_datetime.marshal_dump
                },
                name: person1.name,
              }
            },
            year: car2.year,
          },
          _classes: [
            {
              _class: car2.class.name,
              _class_variables: {
                class_count: 1,
              },
              _instance_variables: {
                count: 1,
              },
            },
            {
              _class: person1.class.name,
              _class_variables: {
                class_count: 1,
              },
              _instance_variables: {
                count: 1,
              },
            }
          ],
        )
        
        object = YASL.load(data)
        expect(object).to eq(car2)
        expect(Car.count).to_not eq(1)
        expect(Car.class_count).to_not eq(1)
        expect(Driving::Person.count).to_not eq(1)
        expect(Driving::Person.class_count).to_not eq(1)
        
        object = YASL.load(data, include_classes: true)
        expect(object).to eq(car2)
        expect(Car.count).to eq(1)
        expect(Car.class_count).to eq(1)
        expect(Driving::Person.count).to eq(1)
        expect(Driving::Person.class_count).to eq(1)
      end
    end
    
    context 'Struct' do
      it 'deserializes struct members of all Ruby basic data types' do
        data = JSON.dump(
          _class: car_struct1.class.name,
          _id: 1,
          _struct_member_values: {
            make: car_struct1.make,
            model: car_struct1.model,
            year: car_struct1.year,
            registration_time: {
              _class: 'Time',
              _data: car_struct1.registration_time.to_datetime.marshal_dump
            },
            registration_date: {
              _class: 'Date',
              _data: car_struct1.registration_date.marshal_dump
            },
            registration_date_time: {
              _class: 'DateTime',
              _data: car_struct1.registration_date_time.marshal_dump
            },
            complex_number: {
              _class: 'Complex',
              _data: car_struct1.complex_number.to_s
            },
            complex_polar_number: {
              _class: 'Complex',
              _data: car_struct1.complex_polar_number.to_s
            },
            rational_number: {
              _class: 'Rational',
              _data: car_struct1.rational_number.to_s
            },
            regex: {
              _class: 'Regexp',
              _data: car_struct1.regex.to_s
            },
            symbol: {
              _class: 'Symbol',
              _data: car_struct1.symbol.to_s
            },
            set: {
              _class: 'Set',
              _data: [
                1,
                {
                  :_class => "Symbol",
                  :_data => "b"
                },
                3.7
              ]
            },
            range: {
              _class: 'Range',
              _data: [car_struct1.range.begin, car_struct1.range.end, car_struct1.range.exclude_end?]
            },
            range_exclusive: {
              _class: 'Range',
              _data: [car_struct1.range_exclusive.begin, car_struct1.range_exclusive.end, car_struct1.range_exclusive.exclude_end?]
            },
          }
        )
        
        object = YASL.load(data)
        
        expect(object).to eq(car_struct1)
      end
         
      it 'recursively deserializes member values and instance variables that are not basic data types' do
        person1
        person2
        
        data = JSON.dump(
          _class: car_struct2.class.name,
          _id: 1,
          _instance_variables: {
            owner: {
              _class: 'Driving::Person',
              _id: 1,
              _instance_variables: {
                dob: {
                  _class: 'Time',
                  _data: person1.dob.to_datetime.marshal_dump
                },
                name: person1.name,
              }
            }
          },
          _struct_member_values: {
            make: car_struct2.make,
            model: car_struct2.model,
            year: car_struct2.year,
          },
          _classes: [
            {
              _class: person1.class.name,
              _class_variables: {
                class_count: 1,
              },
              _instance_variables: {
                count: 1,
              },
            }
          ],
        )
        object = YASL.load(data)
        expect(object).to eq(car_struct2)
        expect(Driving::Person.count).to_not eq(1)
        expect(Driving::Person.class_count).to_not eq(1)
        
        object = YASL.load(data, include_classes: true)
        expect(object).to eq(car_struct2)
        expect(Driving::Person.count).to eq(1)
        expect(Driving::Person.class_count).to eq(1)
      end
    end
    
    it 'deserializes array containing non-JSON basic data type objects' do
      car1
      car2
      car3
      
      person1
      person2
      person3
      
      data = JSON.dump(
        _class: person2.class.name,
        _id: 1,
        _instance_variables: {
          cars: {
            _class: 'Array',
            _data: [
              {
                _class: car3.class.name,
                _id: 1,
                _instance_variables: {
                  make: car3.make,
                  model: car3.model,
                  year: car3.year,
                },
              },
              {
                _class: car4.class.name,
                _id: 2,
                _instance_variables: {
                  make: car4.make,
                  model: car4.model,
                  year: car4.year,
                },
              },
            ]
          },
          dob: {
            _class: 'Time',
            _data: person2.dob.to_datetime.marshal_dump
          },
          name: person2.name,
        },
        _classes: [
          {
            _class: person2.class.name,
            _class_variables: {
              class_count: 1,
            },
            _instance_variables: {
              count: 1,
            },
          },
          {
            _class: car2.class.name,
            _class_variables: {
              class_count: 2,
            },
            _instance_variables: {
              count: 2,
            },
          },
        ],
      )
      
      object = YASL.load(data, include_classes: false)
      expect(object).to eq(person2)
      expect(Car.count).to_not eq(2)
      expect(Car.class_count).to_not eq(2)
      expect(Driving::Person.count).to_not eq(1)
      expect(Driving::Person.class_count).to_not eq(1)
      
      object = YASL.load(data, include_classes: true)
      expect(object).to eq(person2)
      expect(Car.count).to eq(2)
      expect(Car.class_count).to eq(2)
      expect(Driving::Person.count).to eq(1)
      expect(Driving::Person.class_count).to eq(1)
    end
    
    it 'deserializes hash containing non-JSON basic data type objects' do
      car1
      car2
      car3
      
      person1
      person2
      person3
            
      data = JSON.dump(
        _class: person3.class.name,
        _id: 1,
        _instance_variables: {
          cars: {
            _class: 'Hash',
            _data: [
              [
                'car1',
                {
                  _class: car3.class.name,
                  _id: 1,
                  _instance_variables: {
                    make: car3.make,
                    model: car3.model,
                    year: car3.year,
                  },
                },
              ],
              [
                'car2',
                {
                  _class: car4.class.name,
                  _id: 2,
                  _instance_variables: {
                    make: car4.make,
                    model: car4.model,
                    year: car4.year,
                  },
                },
              ]
            ]
          },
          dob: {
            _class: 'Time',
            _data: person3.dob.to_datetime.marshal_dump
          },
          name: person3.name,
        },
        _classes: [
          {
            _class: person3.class.name,
            _class_variables: {
              class_count: 1,
            },
            _instance_variables: {
              count: 1,
            },
          },
          {
            _class: car2.class.name,
            _class_variables: {
              class_count: 2,
            },
            _instance_variables: {
              count: 2,
            },
          },
        ],
      )
      
      object = YASL.load(data, include_classes: false)
      expect(object).to eq(person3)
      expect(Car.count).to_not eq(1)
      expect(Car.class_count).to_not eq(1)
      expect(Driving::Person.count).to_not eq(1)
      expect(Driving::Person.class_count).to_not eq(1)
      
      object = YASL.load(data, include_classes: true)
      expect(object).to eq(person3)
      expect(Car.count).to eq(2)
      expect(Car.class_count).to eq(2)
      expect(Driving::Person.count).to eq(1)
      expect(Driving::Person.class_count).to eq(1)
    end
        
    it 'serializes recursively with cycles' do
      car1
      car2
      car3
      
      person1
      person2
      person3
      person4
      
      data = JSON.dump(
        _class: person4.class.name,
        _id: 1,
        _instance_variables: {
          cars: {
            _class: 'Array',
            _data: [
              {
                _class: car3.class.name,
                _id: 1,
                _instance_variables: {
                  make: car3.make,
                  model: car3.model,
                  owner: {
                    _class: person4.class.name,
                    _id: 1,
                  },
                  year: car3.year,
                },
              },
              {
                _class: car4.class.name,
                _id: 2,
                _instance_variables: {
                  make: car4.make,
                  model: car4.model,
                  owner: {
                    _class: person4.class.name,
                    _id: 1,
                  },
                  year: car4.year,
                },
              },
            ]
          },
          dob: {
            _class: 'Time',
            _data: person4.dob.to_datetime.marshal_dump
          },
          name: person4.name,
        },
        _classes: [
          {
            _class: person4.class.name,
            _class_variables: {
              class_count: 1,
            },
            _instance_variables: {
              count: 1,
            },
          },
          {
            _class: car2.class.name,
            _class_variables: {
              class_count: 2,
            },
            _instance_variables: {
              count: 2,
            },
          },
        ],
      )
      
      object = YASL.load(data) # include_classes: false
      expect(object).to eq(person4)
      expect(Car.count).to_not eq(1)
      expect(Car.class_count).to_not eq(1)
      expect(Driving::Person.count).to_not eq(1)
      expect(Driving::Person.class_count).to_not eq(1)

      object = YASL.load(data, include_classes: true)
      expect(object).to eq(person4)
      expect(Car.count).to eq(2)
      expect(Car.class_count).to eq(2)
      expect(Driving::Person.count).to eq(1)
      expect(Driving::Person.class_count).to eq(1)
    end
      
    context 'top-level classes and modules' do
      it 'deserializes class (adding to classes)' do
        data = JSON.dump(
          _class: 'Car',
          _classes: [
            {
              _class: 'Car',
              _class_variables: {
                class_count: 4,
              },
              _instance_variables: {
                count: 4,
              },
            }
          ]
        )
        object = YASL.load(data, include_classes: false)
        expect(object).to eq(Car)
        expect(Car.count).to_not eq(4)
        expect(Car.class_count).to_not eq(4)
        
        object = YASL.load(data, include_classes: true)
        expect(object).to eq(Car)
        expect(Car.count).to eq(4)
        expect(Car.class_count).to eq(4)
      end
      
      it 'deserializes module (adding to classes since the module singleton class is a class)' do
        data = JSON.dump(
          _class: 'Driving',
          _classes: [
            {
              _class: 'Driving',
              _instance_variables: {
                var: 'var value',
              },
            }
          ]
        )
        
        object = YASL.load(data, include_classes: false)
        expect(object).to eq(Driving)
        expect(Driving.var).to_not eq('var value')
        
        object = YASL.load(data, include_classes: true)
        expect(object).to eq(Driving)
        expect(Driving.var).to eq('var value')
      end
    end
    
    it 'raises error when deserializing data with a class that is not found' do
      data = JSON.dump(
        _class: 'SomeClass',
      )
      
      expect { YASL.load(data) }.to raise_error("Class `SomeClass` does not exist! YASL expects the same classes used for serialization to exist during deserialization.")
      
      data = JSON.dump(
        _class: 23892,
      )

      expect { YASL.load(data) }.to raise_error("Class `23892` does not exist! YASL expects the same classes used for serialization to exist during deserialization.")
      
      data = JSON.dump(
        _class: 'Car',
        _instance_variables: {
          class_attribute: {
            _class: 'OtherClass'
          },
        }
      )
      
      expect { YASL.load(data) }.to raise_error("Class `OtherClass` does not exist! YASL expects the same classes used for serialization to exist during deserialization.")
    end
    
  end
end
