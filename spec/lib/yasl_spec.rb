require 'spec_helper'

RSpec.describe do
  before do
    class Car
      attr_accessor :make, :model, :year
    end
  end
  
  after do
    [
      :Car
    ].each do |class_name|
      Object.send(:remove_const, class_name)
    end
  end
  
  it 'serializes instance variables' do
    car = Car.new
    car.make = 'Mitsubishi'
    car.model = 'Eclipse'
    car.year = '2002'
    
    dump = YASL.dump(car)
    expected_dump = JSON.dump(
      class: {
        name: 'Car'
      },
      make: car.make,
      model: car.model,
      year: car.year,
    )
    expect(dump).to eq(expected_dump)
  end
  
  xit 'serializes struct members' do
  end
end
