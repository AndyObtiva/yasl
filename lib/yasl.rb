require 'json'
require 'date'

module YASL
  JSON_BASIC_DATA_TYPES = [NilClass, String, Integer, Float, Hash, Array, TrueClass, FalseClass]
  RUBY_ONLY_BASIC_DATA_TYPES = [Time, Date, Complex, Rational, Regexp, Symbol, Set, Range]
  RUBY_BASIC_DATA_TYPES = RUBY_ONLY_BASIC_DATA_TYPES + JSON_BASIC_DATA_TYPES
  
  class << self
    def dump(object)
      JSON.dump(dump_structure(object))
    end
    
    def dump_structure(object)
      structure = {}
      if json_basic_data_type?(object)
        structure = object
      elsif ruby_basic_data_type?(object)
        structure[:_class] = object.class.name
        structure[:_data] = ruby_basic_data_type_data(object)
      else
        structure[:_class] = object.class.name
        if !object.instance_variables.empty?
          structure[:_instance_variables] = object.instance_variables.reduce({}) do |instance_vars, var|
            value = object.instance_variable_get(var)
            instance_vars.merge(var.to_s.sub('@', '') => dump_structure(value))
          end
        end
        if object.is_a?(Struct)
          structure[:_member_values] = object.members.reduce({}) do |member_values, member|
            value = object[member]
            value.nil? ? member_values : member_values.merge(member => dump_structure(value))
          end
        end
      end
      structure
    end
    
    def json_basic_data_type?(object)
      type_in?(object, JSON_BASIC_DATA_TYPES)
    end
    
    def ruby_basic_data_type?(object)
      type_in?(object, RUBY_BASIC_DATA_TYPES)
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
      elsif object.is_a?(Set)
        object.to_a
      elsif object.is_a?(Range)
        [object.begin, object.end, object.exclude_end?]
      end
    end
    
    private
    
    def type_in?(object, types)
      types.reduce(false) do |result, klass|
        result || object.is_a?(klass)
      end
    end
    
  end
end
