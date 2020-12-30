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
      car.regex = /^[a-z][1-9]$/
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
  
  describe '#dump' do
    context 'JSON Basic Data Types' do
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
      
      it 'serializes Array Ruby basic data type' do
        array = ['a', 2, 44.4]
        dump = YASL.dump(array)
        
        expected_dump = JSON.dump(
          _class: 'Array',
          _data: array
        )
        expect(dump).to eq(expected_dump)
      end
      
      it 'serializes Hash Ruby basic data type' do
        hash = {key1: 'value1', key2: 'value2'}
        dump = YASL.dump(hash)
        
        expected_dump = JSON.dump(
          _class: 'Hash',
          _data: [
            [
              {
                _class: 'Symbol',
                _data: 'key1',
              },
              'value1'
            ],
            [
              {
                _class: 'Symbol',
                _data: 'key2',
              },
              'value2'
            ],
          ]
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    context 'Ruby objects and basic data types' do
      it 'serializes instance variables of all Ruby basic data types' do
#         dump = YASL.dump(car1, include_classes: true)
#
#         expected_dump = JSON.dump(
#           _class: car1.class.name,
#           _id: 1,
#           _instance_variables: {
#             class_attribute: {
#               _class: 'Car',
#             },
#             complex_number: {
#               _class: 'Complex',
#               _data: car1.complex_number.to_s
#             },
#             complex_polar_number: {
#               _class: 'Complex',
#               _data: car1.complex_polar_number.to_s
#             },
#             make: car1.make,
#             model: car1.model,
#             module_attribute: {
#               _class: 'Driving',
#             },
#             range: {
#               _class: 'Range',
#               _data: [car1.range.begin, car1.range.end, car1.range.exclude_end?]
#             },
#             range_exclusive: {
#               _class: 'Range',
#               _data: [car1.range_exclusive.begin, car1.range_exclusive.end, car1.range_exclusive.exclude_end?]
#             },
#             rational_number: {
#               _class: 'Rational',
#               _data: car1.rational_number.to_s
#             },
#             regex: {
#               _class: 'Regexp',
#               _data: car1.regex.to_s
#             },
#             registration_date: {
#               _class: 'Date',
#               _data: car1.registration_date.marshal_dump
#             },
#             registration_date_time: {
#               _class: 'DateTime',
#               _data: car1.registration_date_time.marshal_dump
#             },
#             registration_time: {
#               _class: 'Time',
#               _data: car1.registration_time.to_datetime.marshal_dump
#             },
#             set: {
#               _class: 'Set',
#               _data: [
#                 1,
#                 {
#                   :_class => "Symbol",
#                   :_data => "b"
#                 },
#                 3.7
#               ]
#             },
#             symbol: {
#               _class: 'Symbol',
#               _data: car1.symbol.to_s
#             },
#             year: car1.year,
#           },
#           _classes: [
#             {
#               _class: car2.class.name,
#               _class_variables: {
#                 class_count: 1,
#               },
#               _instance_variables: {
#                 count: 1,
#               },
#             },
#           ],
#         )
#         expect(dump).to eq(expected_dump)
        
        dump = YASL.dump(car1) # include_classes: false
        
        expected_dump = JSON.dump(
          _class: car1.class.name,
          _id: 1,
          _instance_variables: {
            class_attribute: {
              _class: 'Car',
            },
            complex_number: {
              _class: 'Complex',
              _data: car1.complex_number.to_s
            },
            complex_polar_number: {
              _class: 'Complex',
              _data: car1.complex_polar_number.to_s
            },
            make: car1.make,
            model: car1.model,
            module_attribute: {
              _class: 'Driving',
            },
            range: {
              _class: 'Range',
              _data: [car1.range.begin, car1.range.end, car1.range.exclude_end?]
            },
            range_exclusive: {
              _class: 'Range',
              _data: [car1.range_exclusive.begin, car1.range_exclusive.end, car1.range_exclusive.exclude_end?]
            },
            rational_number: {
              _class: 'Rational',
              _data: car1.rational_number.to_s
            },
            regex: {
              _class: 'Regexp',
              _data: car1.regex.to_s
            },
            registration_date: {
              _class: 'Date',
              _data: car1.registration_date.marshal_dump
            },
            registration_date_time: {
              _class: 'DateTime',
              _data: car1.registration_date_time.marshal_dump
            },
            registration_time: {
              _class: 'Time',
              _data: car1.registration_time.to_datetime.marshal_dump
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
            symbol: {
              _class: 'Symbol',
              _data: car1.symbol.to_s
            },
            year: car1.year,
          },
        )
        expect(dump).to eq(expected_dump)
      end
      
      it 'recursively serializes instance variables that are not basic data types' do
        dump = YASL.dump(car2, include_classes: true)
        
        expected_dump = JSON.dump(
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
        expect(dump).to eq(expected_dump)
        
        dump = YASL.dump(car2) # include_classes: false
        
        expected_dump = JSON.dump(
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
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    context 'Struct' do
      it 'serializes struct members of all Ruby basic data types' do
        dump = YASL.dump(car_struct1)
        
        expected_dump = JSON.dump(
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
        expect(dump).to eq(expected_dump)
      end
         
      it 'recursively serializes member values and instance variables that are not basic data types' do
        dump = YASL.dump(car_struct2, include_classes: true)
        
        expected_dump = JSON.dump(
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
        expect(dump).to eq(expected_dump)
        
        dump = YASL.dump(car_struct2) # include_classes: false
        
        expected_dump = JSON.dump(
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
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    it 'serializes array containing non-JSON basic data type objects' do
      dump = YASL.dump(person2, include_classes: true)
      
      expected_dump = JSON.dump(
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
      expect(dump).to eq(expected_dump)
      
      dump = YASL.dump(person2) # include_classes: false
      
      expected_dump = JSON.dump(
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
      )
      expect(dump).to eq(expected_dump)
    end
    
    it 'serializes hash containing non-JSON basic data type objects' do
      dump = YASL.dump(person3, include_classes: true)
      
      expected_dump = JSON.dump(
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
      expect(dump).to eq(expected_dump)

      dump = YASL.dump(person3,) # include_classes: false
      
      expected_dump = JSON.dump(
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
      )
      expect(dump).to eq(expected_dump)
    end
    
    it 'serializes recursively with cycles' do
      dump = YASL.dump(person4, include_classes: true)
      
      expected_dump = JSON.dump(
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
      expect(dump).to eq(expected_dump)
      
      dump = YASL.dump(person4, include_classes: false)
      
      expected_dump = JSON.dump(
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
      )
      expect(dump).to eq(expected_dump)
    end
    
    context 'top-level classes and modules' do
      it 'serializes class (adding to classes)' do
        car1
        car2
        car3
        car4
        
        dump = YASL.dump(Car, include_classes: true)
        
        expected_dump = JSON.dump(
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
        expect(dump).to eq(expected_dump)
        
        dump = YASL.dump(Car, include_classes: false)
        
        expected_dump = JSON.dump(
          _class: 'Car',
        )
        expect(dump).to eq(expected_dump)
      end
      
      it 'serializes module (adding to classes since the module singleton class is a class)' do
        Driving.set_var!
        dump = YASL.dump(Driving, include_classes: true)
        
        expected_dump = JSON.dump(
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
        expect(dump).to eq(expected_dump)
        
        dump = YASL.dump(Driving) # include_classes: false
        
        expected_dump = JSON.dump(
          _class: 'Driving',
        )
        expect(dump).to eq(expected_dump)
      end
    end
    
    it 'silently ignores non-serializable objects like `Proc`, `Binding`, and `IO`' do
      dump = YASL.dump(Class.new {})
      expect(dump).to eq("null")
      
      dump = YASL.dump(Module.new {})
      expect(dump).to eq("null")
      
      file = File.new(__FILE__)
      hash = {
        proc: lambda {},
        binding: TOPLEVEL_BINDING,
        io: file,
        file_stat: file.stat,
        dir: Dir.new(__dir__),
        basic_socket: (TCPSocket.new('www.google.com', 80) rescue lambda {}), # rescue to avoid network error hanging tests
        anonymous_class: Class.new {},
        anonymous_module: Module.new {},
        match_data: //.match(''),
        method: method(:to_s),
        unbound_method: self.class.instance_method(:to_s),
        thread: Thread.new {},
        thread_group: ThreadGroup.new,
        continuation: (callcc{|cc| $cc = cc} rescue lambda {}), # rescue to avoid alloc issue in JRuby
        other: 'valid data',
      }
      
      dump = YASL.dump(hash)
      expect(dump).to eq("{\"_class\":\"Hash\",\"_data\":[[{\"_class\":\"Symbol\",\"_data\":\"other\"},\"valid data\"]]}")
      
      array = [
        lambda {},
        TOPLEVEL_BINDING,
        file,
        file.stat,
        Dir.new(__dir__),
        (TCPSocket.new('www.google.com', 80) rescue lambda {}), # rescue to avoid network error hanging tests
        Class.new {},
        Module.new {},
        //.match(''),
        method(:to_s),
        self.class.instance_method(:to_s),
        Thread.new {},
        ThreadGroup.new,
        (callcc{|cc| $cc = cc} rescue lambda {}),
        'valid data',
      ]
      
      dump = YASL.dump(array)
      expect(dump).to eq("{\"_class\":\"Array\",\"_data\":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,\"valid data\"]}")
      
      set = Set.new(array)
      
      dump = YASL.dump(set)
      expect(dump).to eq("{\"_class\":\"Set\",\"_data\":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,\"valid data\"]}")
      
      struct = CarStruct.new(make: lambda {})
      struct.owner = Class.new {}
      
      dump = YASL.dump(struct)
      expect(dump).to eq("{\"_class\":\"CarStruct\",\"_id\":1}")
      
      object = Car.new
      object.make = lambda {}
      object.owner = Module.new {}
      Car.instance_variable_set(:@count, lambda {})
      Car.class_variable_set(:@@class_count, lambda {})

      dump = YASL.dump(object, include_classes: true)
      expect(dump).to eq("{\"_class\":\"Car\",\"_id\":1,\"_classes\":[{\"_class\":\"Car\"}]}")
    end
    
  end
  
end
