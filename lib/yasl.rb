require 'json'
require 'date'

module YASL
  JSON_BASIC_DATA_TYPES = [NilClass, String, Numeric, Hash, Array, TrueClass, FalseClass]
  RUBY_ONLY_BASIC_DATA_TYPES = [Time, Date, Complex, Rational, Regexp, Symbol]
  
  class << self
    def dump(object)
      JSON.dump(dump_structure(object))
    end
    
    def dump_structure(object)
      hash = {}
      hash[:_class] = object.class.name
      if ruby_basic_data_type?(object)
        hash[:_data] = ruby_basic_data_type_data(object)
      else
        hash[:_instance_variables] = {}
        object.instance_variables.each do |var|
          value = object.instance_variable_get(var)
          # TODO consider using marshal_dump and marshal_load for date objects
          # e.g. for marshalling time, convert to datetime first: DateTime.new.marshal_load(JSON.load(JSON.dump(t.to_datetime.marshal_dump))).to_time
          value = dump_structure(value) unless json_only_basic_data_type?(value)
          hash[:_instance_variables][var.to_s.sub('@', '')] = value
        end
      end
      hash
    end
    
    def json_only_basic_data_type?(object)
      json_basic_data_type?(object) && !ruby_only_basic_data_type?(object)
    end
    
    def json_basic_data_type?(object)
      JSON_BASIC_DATA_TYPES.reduce(false) do |result, klass|
        result || object.is_a?(klass)
      end
    end
    
    def ruby_only_basic_data_type?(object)
      RUBY_ONLY_BASIC_DATA_TYPES.reduce(false) do |result, klass|
        result || object.is_a?(klass)
      end
    end
    
    def ruby_basic_data_type?(object)
      json_basic_data_type?(object) || ruby_only_basic_data_type?(object)
    end
    
    def ruby_basic_data_type_data(object)
      # TODO Consider the new Ruby pattern matching feature for this
      if object.is_a?(Time)
        object.to_datetime.marshal_dump
      elsif object.is_a?(Date)
        object.marshal_dump
      elsif object.is_a?(Complex)
        object.to_s
      elsif object.is_a?(Rational)
        object.to_s
      elsif object.is_a?(Regexp)
        object.to_s
      elsif object.is_a?(Symbol)
        object.to_s
      end
    end
  end
end
