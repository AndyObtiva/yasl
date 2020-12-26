require 'json'
require 'date'

module YASL
  JSON_BASIC_DATA_TYPES = [NilClass, String, Integer, Float, TrueClass, FalseClass]
  RUBY_ONLY_BASIC_DATA_TYPES = [Time, Date, Complex, Rational, Regexp, Symbol, Set, Range, Array, Hash]
  RUBY_BASIC_DATA_TYPES = RUBY_ONLY_BASIC_DATA_TYPES + JSON_BASIC_DATA_TYPES
  
  class << self
    def dump(object)
      JSON.dump(dump_structure_with_classes(object))
    end
    
    def dump_structure_with_classes(object)
      classes = []
      original_classes = classes.clone
      structure = dump_structure(object, classes)
      while classes.size > original_classes.size
        diff = (classes - original_classes)
        original_classes = classes.clone
        diff.each do |klass|
          unless klass.class_variables.empty? && klass.instance_variables.empty?
            structure[:_classes] ||= []
            structure[:_classes] << dump_structure(klass, classes)
          end
        end
      end
      structure
    end
    
    def dump_structure(object, classes = nil)
      structure = {}
      if json_basic_data_type?(object)
        structure = object
      elsif ruby_basic_data_type?(object)
        structure[:_class] = object.class.name
        structure[:_data] = ruby_basic_data_type_data(object, classes)
      else
        klass = object.is_a?(Class) ? object : object.class
        structure[:_class] = klass.name
        classes << klass unless classes.nil? || classes.include?(klass)
        if object.respond_to?(:class_variables) && !object.class_variables.empty?
          structure[:_class_variables] = object.class_variables.reduce({}) do |class_vars, var|
            value = object.class_variable_get(var)
            class_vars.merge(var.to_s.sub('@@', '') => dump_structure(value, classes))
          end
        end
        if !object.instance_variables.empty?
          structure[:_instance_variables] = object.instance_variables.reduce({}) do |instance_vars, var|
            value = object.instance_variable_get(var)
            instance_vars.merge(var.to_s.sub('@', '') => dump_structure(value, classes))
          end
        end
        if object.is_a?(Struct)
          structure[:_member_values] = object.members.reduce({}) do |member_values, member|
            value = object[member]
            value.nil? ? member_values : member_values.merge(member => dump_structure(value, classes))
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
    
    def ruby_basic_data_type_data(object, classes = nil)
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
      elsif object.is_a?(Array)
        object.map {|object| dump_structure(object, classes)}
      elsif object.is_a?(Hash)
        object.reduce({}) do |new_hash, pair|
          new_hash.merge(dump_structure(pair.first, classes) => dump_structure(pair.last, classes))
        end
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
