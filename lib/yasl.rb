require 'json'
require 'date'

module YASL
  class << self
    def dump(object)
      JSON.dump(dumpable_hash(object))
    end
    
    def dumpable_hash(object)
      hash = {class: {}}
      hash[:class][:name] = object.class.name
      if ruby_basic_data_type?(object)
        hash[:ruby_basic_data_type_data] = ruby_basic_data_type_data(object)
      else
        object.instance_variables.each do |var|
          value = object.instance_variable_get(var)
          # TODO consider using marshal_dump and marshal_load for date objects
          # e.g. for marshalling time, convert to datetime first: DateTime.new.marshal_load(JSON.load(JSON.dump(t.to_datetime.marshal_dump))).to_time
          value = dumpable_hash(value) unless json_basic_data_type?(value)
          hash[var.to_s.sub('@', '')] = value
        end
      end
      hash
    end
    
    def json_basic_data_type?(object)
      object.nil? ||
        object.is_a?(String) ||
        object.is_a?(Numeric) ||
        object.is_a?(Hash) ||
        object.is_a?(Array) || # TODO check of Set and other enumerables qualify too
        object.is_a?(TrueClass) ||
        object.is_a?(FalseClass)
    end
    
    def ruby_basic_data_type?(object)
      json_basic_data_type?(object) ||
        object.is_a?(Time)
    end
    
    def ruby_basic_data_type_data(object)
      # TODO Consider the new Ruby pattern matching feature for this
      if object.is_a?(Time)
        object.to_datetime.marshal_dump
      end
    end
  end
end
