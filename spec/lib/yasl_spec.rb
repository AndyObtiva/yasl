require 'spec_helper'

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
                :regex,
                :symbol,
                :set,
                :range,
                :range_exclusive,
                :owner
end

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

module Driving
  class Person
    attr_accessor :name,
                  :dob
  end
  
end

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
      car.regex = /^[a-z][1-9]$/
      car.symbol = :good
      car.set = Set.new([1, 'b', 3.7])
      car.range = (1..7)
      car.range_exclusive = (1...7)
    end
  }
  
  let(:car2) {
    Car.new.tap do |car|
      car.make = 'Mitsubishi'
      car.model = 'Eclipse'
      car.year = '2002'
      car.owner = person2
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
      car.regex = /^[a-z][1-9]$/
      car.symbol = :good
      car.set = Set.new([1, 'b', 3.7])
      car.range = (1..7)
      car.range_exclusive = (1...7)
    end
  }
  
  let(:car_struct2) {
    CarStruct.new.tap do |car|
      car.make = 'Mitsubishi'
      car.model = 'Eclipse'
      car.year = '2002'
      car.owner = person2
    end
  }
  
  let(:person2) {
    Driving::Person.new.tap do |person|
      person.name = 'Sean Tux'
      person.dob = Time.new(2000, 11, 28)
    end
  }
  
  describe '#dump' do
    it 'serializes Integer JSON basic data type' do
      dump = YASL.dump(3)
      
      expect(dump).to eq(JSON.dump(3))
    end
    
    it 'serializes Float JSON basic data type' do
      dump = YASL.dump(3.14)
      
      expect(dump).to eq(JSON.dump(3.14))
    end
    
    it 'serializes String JSON basic data type' do
      dump = YASL.dump('Sean')
      
      expect(dump).to eq(JSON.dump('Sean'))
    end
    
    it 'serializes Boolean JSON basic data type' do
      expect(YASL.dump(true)).to eq(JSON.dump(true))
      expect(YASL.dump(false)).to eq(JSON.dump(false))
    end
    
    it 'serializes Nil JSON basic data type' do
      dump = YASL.dump(nil)
      
      expect(dump).to eq(JSON.dump(nil))
    end
    
    it 'serializes Array JSON basic data type' do
      array = ['a', 2, 44.4]
      dump = YASL.dump(array)
      
      expect(dump).to eq(JSON.dump(array))
    end
    
    it 'serializes Hash JSON basic data type' do
      hash = {key1: 'value1', key2: 'value2'}
      dump = YASL.dump(hash)
      
      expect(dump).to eq(JSON.dump(hash))
    end
    
    context 'Ruby objects and basic data types' do
      it 'serializes instance variables of all Ruby basic data types' do
        dump = YASL.dump(car1)
        
        expected_dump = JSON.dump(
          _class: car1.class.name,
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
              _data: car1.set.to_a
            },
            range: {
              _class: 'Range',
              _data: [car1.range.begin, car1.range.end, car1.range.exclude_end?]
            },
            range_exclusive: {
              _class: 'Range',
              _data: [car1.range_exclusive.begin, car1.range_exclusive.end, car1.range_exclusive.exclude_end?]
            },
          }
        )
        expect(dump).to eq(expected_dump)
      end
      
      it 'recursively (1 level deep) serializes instance variables that are not basic data types' do
        dump = YASL.dump(car2)
        
        expected_dump = JSON.dump(
          _class: car2.class.name,
          _instance_variables: {
            make: car2.make,
            model: car2.model,
            year: car2.year,
            owner: {
              _class: 'Driving::Person',
              _instance_variables: {
                name: person2.name,
                dob: {
                  _class: 'Time',
                  _data: person2.dob.to_datetime.marshal_dump
                }
              }
            }
          }
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    
    context 'Struct' do
      it 'serializes struct members of all Ruby basic data types' do
        dump = YASL.dump(car_struct1)
        
        expected_dump = JSON.dump(
          _class: car_struct1.class.name,
          _member_values: {
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
              _data: car_struct1.set.to_a
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
        expect(dump).to eq(expected_dump)
      end
         
      it 'recursively (1 level deep) serializes member values and instance variables that are not basic data types' do
        dump = YASL.dump(car_struct2)
        
        expected_dump = JSON.dump(
          _class: car_struct2.class.name,
          _instance_variables: {
            owner: {
              _class: 'Driving::Person',
              _instance_variables: {
                name: person2.name,
                dob: {
                  _class: 'Time',
                  _data: person2.dob.to_datetime.marshal_dump
                }
              }
            }
          },
          _member_values: {
            make: car_struct2.make,
            model: car_struct2.model,
            year: car_struct2.year,
          },
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    xit 'serializes class variables'
    xit 'handle exception with instance variable matching class name'
    xit 'handle cycles'
  end
  
  describe '#load' do
    xit 'deserializes basic object (no nesting)'
  end
end
