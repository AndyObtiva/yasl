require 'spec_helper'

RSpec.describe do
  before do
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
                    :owner
    end
    class Person
      attr_accessor :name,
                    :dob
    end
  end
  
  after do
    [
      :Car,
      :Person,
    ].each do |class_name|
      Object.send(:remove_const, class_name)
    end
  end
  
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
    end
  }
  
  let(:person1) {
    Person.new.tap do |person|
      person.name = 'Sean Tux'
      person.dob = Time.new(2000, 11, 28)
    end
  }
  
  describe '#dump' do
    it 'serializes instance variables of all Ruby basic data types' do
      car1
      
      dump = YASL.dump(car1)
      
      expected_dump = JSON.dump(
        class: {
          name: car1.class.name
        },
        make: car1.make,
        model: car1.model,
        year: car1.year,
        registration_time: {
          class: {
            name: 'Time'
          },
          ruby_basic_data_type_data: car1.registration_time.to_datetime.marshal_dump
        },
        registration_date: {
          class: {
            name: 'Date'
          },
          ruby_basic_data_type_data: car1.registration_date.marshal_dump
        },
        registration_date_time: {
          class: {
            name: 'DateTime'
          },
          ruby_basic_data_type_data: car1.registration_date_time.marshal_dump
        },
        complex_number: {
          class: {
            name: 'Complex'
          },
          ruby_basic_data_type_data: car1.complex_number.to_s
        },
        complex_polar_number: {
          class: {
            name: 'Complex'
          },
          ruby_basic_data_type_data: car1.complex_polar_number.to_s
        },
        rational_number: {
          class: {
            name: 'Rational'
          },
          ruby_basic_data_type_data: car1.rational_number.to_s
        },
      )
      expect(dump).to eq(expected_dump)
    end
    
    it 'recursively (1 level deep) serializes instance variables that are not basic data types' do
      car1
      person1
      car1.owner = person1
      
      dump = YASL.dump(car1)
      
      # TODO refactor this dump structure
      expected_dump = JSON.dump(
        class: {
          name: car1.class.name
        },
        make: car1.make,
        model: car1.model,
        year: car1.year,
        registration_time: {
          class: {
            name: 'Time'
          },
          ruby_basic_data_type_data: car1.registration_time.to_datetime.marshal_dump
        },
        registration_date: {
          class: {
            name: 'Date'
          },
          ruby_basic_data_type_data: car1.registration_date.marshal_dump
        },
        registration_date_time: {
          class: {
            name: 'DateTime'
          },
          ruby_basic_data_type_data: car1.registration_date_time.marshal_dump
        },
        complex_number: {
          class: {
            name: 'Complex'
          },
          ruby_basic_data_type_data: car1.complex_number.to_s
        },
        complex_polar_number: {
          class: {
            name: 'Complex'
          },
          ruby_basic_data_type_data: car1.complex_polar_number.to_s
        },
        rational_number: {
          class: {
            name: 'Rational'
          },
          ruby_basic_data_type_data: car1.rational_number.to_s
        },
        owner: {
          class: {
            name: 'Person'
          },
          name: person1.name,
          dob: {
            class: {
              name: 'Time'
            },
            ruby_basic_data_type_data: person1.dob.to_datetime.marshal_dump
          }
        }
      )
      expect(dump).to eq(expected_dump)
    end
    
    
    xit 'serializes namespaced class' do
    end
    xit 'serializes rational'
    xit 'serializes regex'
    xit 'serializes symbol'
    xit 'serializes sets'
    xit 'serializes enumerables'
    xit 'serializes struct members' do
    end
    xit 'handle exception with instance variable matching class name'
  end
  
  describe '#load' do
    xit 'deserializes basic object (no nesting)'
  end
end
