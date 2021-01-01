require 'spec_helper'

RSpec.describe Struct do
  before(:all) do
    OriginalStruct = Struct
    load File.expand_path(File.join(__dir__, '..', '..', '..', '..', 'lib/yasl/ext/struct.rb'))
  end
  
  after(:all) do
    Struct = OriginalStruct
    Object.send(:remove_const, :PersonStruct) if Object.constants.include?(:PersonStruct)
  end

  let(:full_name) {'Sean Hux'}
  let(:age) {48}
  
  context 'keyword_init: true' do
    it 'builds a new anonymous class, can set/get attributes, and provide equality methods' do
      struct = Struct.new(:full_name, :age, keyword_init: true)
      expect(struct.name).to be_nil
      
      object = struct.new(full_name: full_name, age: age)
      
      # getters
      expect(object.full_name).to eq(full_name)
      expect(object[:full_name]).to eq(full_name)
      expect(object['full_name']).to eq(full_name)
      
      expect(object.age).to eq(age)
      expect(object[:age]).to eq(age)
      expect(object['age']).to eq(age)
      
      expect(object.members).to eq([:full_name, :age])
      expect(object.each_pair).to be_a(Enumerator)
      expect(object.each_pair.to_a).to eq([[:full_name, full_name], [:age, age]])
      expect(object.each).to be_a(Enumerator)
      expect(object.each.to_a).to eq([full_name, age])
      expect(object.select {|value| value.is_a?(Integer)}).to eq([age])
      expect(object.to_h).to eq(full_name: full_name, age: age)
      expect(object.to_a).to eq([full_name, age])
      expect(object.size).to eq(2)
      expect(object.length).to eq(2)
      
      # setters
      
      object.full_name = 'Shaw Gibbins'
      expect(object.full_name).to eq('Shaw Gibbins')
      expect(object['full_name']).to eq('Shaw Gibbins')
      expect(object[:full_name]).to eq('Shaw Gibbins')
      
      object[:full_name] = 'Andy Griffith'
      expect(object.full_name).to eq('Andy Griffith')
      expect(object['full_name']).to eq('Andy Griffith')
      expect(object[:full_name]).to eq('Andy Griffith')
      
      object['full_name'] = 'Bob Macintosh'
      expect(object.full_name).to eq('Bob Macintosh')
      expect(object['full_name']).to eq('Bob Macintosh')
      expect(object[:full_name]).to eq('Bob Macintosh')
      
      object['full_name'] = {first_name: 'Bob', last_name: 'Macintosh'}
      expect(object.dig(:full_name, :first_name)).to eq('Bob')
      
      # equals
      object.full_name = full_name
      object2 = struct.new(full_name: full_name, age: age)
      expect(object2.equal?(object)).to eq(false)
      expect(object2.eql?(object)).to eq(true)
      expect(object2 == object).to eq(true)
      expect(object2.hash).to eq(object.hash)
    end
        
    it 'builds a new named class with string class name, can set/get attributes, and provide equality methods' do
      struct = Struct.new('PersonStruct', :full_name, :age, keyword_init: true)
      expect(struct).to eq(Struct::PersonStruct)
      expect(Struct::PersonStruct.name).to eq('Struct::PersonStruct')
      
      object = Struct::PersonStruct.new(full_name: full_name, age: age)
      
      # getters
      expect(object.full_name).to eq(full_name)
      expect(object[:full_name]).to eq(full_name)
      expect(object['full_name']).to eq(full_name)
      
      expect(object.age).to eq(age)
      expect(object[:age]).to eq(age)
      expect(object['age']).to eq(age)
      
      expect(object.members).to eq([:full_name, :age])
      expect(object.each_pair).to be_a(Enumerator)
      expect(object.each_pair.to_a).to eq([[:full_name, full_name], [:age, age]])
      expect(object.each).to be_a(Enumerator)
      expect(object.each.to_a).to eq([full_name, age])
      expect(object.select {|value| value.is_a?(Integer)}).to eq([age])
      expect(object.to_h).to eq(full_name: full_name, age: age)
      expect(object.to_a).to eq([full_name, age])
      expect(object.size).to eq(2)
      expect(object.length).to eq(2)
      
      # setters
      
      object.full_name = 'Shaw Gibbins'
      expect(object.full_name).to eq('Shaw Gibbins')
      expect(object['full_name']).to eq('Shaw Gibbins')
      expect(object[:full_name]).to eq('Shaw Gibbins')
      
      object[:full_name] = 'Andy Griffith'
      expect(object.full_name).to eq('Andy Griffith')
      expect(object['full_name']).to eq('Andy Griffith')
      expect(object[:full_name]).to eq('Andy Griffith')
      
      object['full_name'] = 'Bob Macintosh'
      expect(object.full_name).to eq('Bob Macintosh')
      expect(object['full_name']).to eq('Bob Macintosh')
      expect(object[:full_name]).to eq('Bob Macintosh')
      
      object['full_name'] = {first_name: 'Bob', last_name: 'Macintosh'}
      expect(object.dig(:full_name, :first_name)).to eq('Bob')
      
      # equals
      object.full_name = full_name
      object2 = struct.new(full_name: full_name, age: age)
      expect(object2.equal?(object)).to eq(false)
      expect(object2.eql?(object)).to eq(true)
      expect(object2 == object).to eq(true)
      expect(object2.hash).to eq(object.hash)
    end
    
    it 'raises error if class name does not start with capital letter' do
      expect {
        Struct.new('personStruct', :full_name, :age, keyword_init: true)
      }.to raise_error(NameError, 'identifier name needs to be constant')
    end
    
    it 'raises error if no attributes are passed in' do
      expect {Struct.new}.to raise_error(ArgumentError)
    end
    
    it 'raises error if an attribute is nil' do
      expect {Struct.new(nil)}.to raise_error('Arguments cannot be nil')
      expect {Struct.new(:name, nil, 'age')}.to raise_error('Arguments cannot be nil')
    end
  end
  
  context 'keyword_init: false' do
    it 'builds a new anonymous class, can set/get attributes, and provide equality methods' do
      struct = Struct.new(:full_name, 'age')
      expect(struct.name).to be_nil
      
      object = struct.new(full_name, age)
      
      # getters
      expect(object.full_name).to eq(full_name)
      expect(object[:full_name]).to eq(full_name)
      expect(object['full_name']).to eq(full_name)
      
      expect(object.age).to eq(age)
      expect(object[:age]).to eq(age)
      expect(object['age']).to eq(age)
      
      expect(object.members).to eq([:full_name, :age])
      expect(object.each_pair).to be_a(Enumerator)
      expect(object.each_pair.to_a).to eq([[:full_name, full_name], [:age, age]])
      expect(object.each).to be_a(Enumerator)
      expect(object.each.to_a).to eq([full_name, age])
      expect(object.select {|value| value.is_a?(Integer)}).to eq([age])
      expect(object.to_h).to eq(full_name: full_name, age: age)
      expect(object.to_a).to eq([full_name, age])
      expect(object.size).to eq(2)
      expect(object.length).to eq(2)
      
      # setters
      
      object.full_name = 'Shaw Gibbins'
      expect(object.full_name).to eq('Shaw Gibbins')
      expect(object['full_name']).to eq('Shaw Gibbins')
      expect(object[:full_name]).to eq('Shaw Gibbins')
      
      object[:full_name] = 'Andy Griffith'
      expect(object.full_name).to eq('Andy Griffith')
      expect(object['full_name']).to eq('Andy Griffith')
      expect(object[:full_name]).to eq('Andy Griffith')
      
      object['full_name'] = 'Bob Macintosh'
      expect(object.full_name).to eq('Bob Macintosh')
      expect(object['full_name']).to eq('Bob Macintosh')
      expect(object[:full_name]).to eq('Bob Macintosh')
      
      object['full_name'] = {first_name: 'Bob', last_name: 'Macintosh'}
      expect(object.dig(:full_name, :first_name)).to eq('Bob')
      
      # equals
      object.full_name = full_name
      object2 = struct.new(full_name, age)
      expect(object2.equal?(object)).to eq(false)
      expect(object2.eql?(object)).to eq(true)
      expect(object2 == object).to eq(true)
      expect(object2.hash).to eq(object.hash)
    end
    
    it 'builds a new named class with string class name, can set/get attributes, and provide equality methods' do
      struct = Struct.new('PersonStruct', :full_name, :age, keyword_init: false)
      expect(struct).to eq(Struct::PersonStruct)
      expect(Struct::PersonStruct.name).to eq('Struct::PersonStruct')
      
      object = Struct::PersonStruct.new(full_name, age)
      
      # getters
      expect(object.full_name).to eq(full_name)
      expect(object[:full_name]).to eq(full_name)
      expect(object['full_name']).to eq(full_name)
      
      expect(object.age).to eq(age)
      expect(object[:age]).to eq(age)
      expect(object['age']).to eq(age)
      
      expect(object.members).to eq([:full_name, :age])
      expect(object.each_pair).to be_a(Enumerator)
      expect(object.each_pair.to_a).to eq([[:full_name, full_name], [:age, age]])
      expect(object.each).to be_a(Enumerator)
      expect(object.each.to_a).to eq([full_name, age])
      expect(object.select {|value| value.is_a?(Integer)}).to eq([age])
      expect(object.to_h).to eq(full_name: full_name, age: age)
      expect(object.to_a).to eq([full_name, age])
      expect(object.size).to eq(2)
      expect(object.length).to eq(2)
      
      # setters
      
      object.full_name = 'Shaw Gibbins'
      expect(object.full_name).to eq('Shaw Gibbins')
      expect(object['full_name']).to eq('Shaw Gibbins')
      expect(object[:full_name]).to eq('Shaw Gibbins')
      
      object[:full_name] = 'Andy Griffith'
      expect(object.full_name).to eq('Andy Griffith')
      expect(object['full_name']).to eq('Andy Griffith')
      expect(object[:full_name]).to eq('Andy Griffith')
      
      object['full_name'] = 'Bob Macintosh'
      expect(object.full_name).to eq('Bob Macintosh')
      expect(object['full_name']).to eq('Bob Macintosh')
      expect(object[:full_name]).to eq('Bob Macintosh')
      
      object['full_name'] = {first_name: 'Bob', last_name: 'Macintosh'}
      expect(object.dig(:full_name, :first_name)).to eq('Bob')
      
      # equals
      object.full_name = full_name
      object2 = struct.new(full_name, age)
      expect(object2.equal?(object)).to eq(false)
      expect(object2.eql?(object)).to eq(true)
      expect(object2 == object).to eq(true)
      expect(object2.hash).to eq(object.hash)
    end
  end
end
