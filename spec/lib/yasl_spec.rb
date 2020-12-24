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
                :owner
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
  
  let(:person2) {
    Driving::Person.new.tap do |person|
      person.name = 'Sean Tux'
      person.dob = Time.new(2000, 11, 28)
    end
  }
  
  describe '#dump' do
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
        }
      )
      expect(dump).to eq(expected_dump)
    end
    
    it 'recursively (1 level deep) serializes instance variables that are not basic data types' do
      dump = YASL.dump(car2)
      
      # TODO refactor this dump structure
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
    
    xit 'serializes set'
    xit 'serializes enumerables'
    xit 'serializes struct members'
    xit 'serializes class variables'
    xit 'handle exception with instance variable matching class name'
  end
  
  describe '#load' do
    xit 'deserializes basic object (no nesting)'
  end
end
