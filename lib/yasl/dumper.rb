module YASL
  class Dumper
    attr_reader :object, :classes, :class_objects
    
    def initialize(object)
      @object = object
      @classes = []
      @class_objects = {}
    end
    
    def dump(include_classes: true)
      structure = dump_structure(object)
      structure.merge!(dump_classes_structure(object)) if include_classes && structure.is_a?(Hash)
      structure
    end
    
    def dump_structure(object, for_classes: false)
      structure = {}
      if top_level_class?(object, for_classes)
        structure[:_class] = object.name
        add_to_classes(object)
      elsif YASL.json_basic_data_type?(object)
        structure = object
      elsif YASL.ruby_basic_data_type?(object)
        structure[:_class] = object.class.name
        structure[:_data] = dump_ruby_basic_data_type_data(object)
      else
        structure.merge!(dump_non_basic_data_type_structure(object))
      end
      structure
    end
    
    def dump_classes_structure(object)
      structure = {}
      structure[:_classes] ||= []
      @original_classes = []
      while classes.size > @original_classes.size
        diff = (classes - @original_classes)
        @original_classes = classes.clone
        diff.each { |klass| structure[:_classes] << dump_class_structure(klass) }
      end
      structure[:_classes] = structure[:_classes].compact
      structure.delete(:_classes) if structure[:_classes].empty?
      structure
    end
    
    def dump_class_structure(klass)
      dump_structure(klass, for_classes: true) unless klass.class_variables.empty? && klass.instance_variables.empty?
    end
    
    def dump_ruby_basic_data_type_data(object)
      case object
      when Time
        object.to_datetime.marshal_dump
      when Date
        object.marshal_dump
      when Complex, Rational, Regexp, Symbol
        object.to_s
      when Set
        object.to_a
      when Range
        [object.begin, object.end, object.exclude_end?]
      when Array
        object.map {|object| dump_structure(object)}
      when Hash
        object.reduce({}) do |new_hash, pair|
          new_hash.merge(dump_structure(pair.first) => dump_structure(pair.last))
        end
      end
    end
    
    def dump_non_basic_data_type_structure(object)
      structure = {}
      klass = class_for(object)
      add_to_classes(klass)
      structure[:_class] = klass.name
      the_object_id = object_id(object)
      if the_object_id.nil?
        structure.merge!(dump_new_non_basic_data_type_structure(object))
      else
        structure[:_id] = the_object_id
      end
      structure
    end
    
    def dump_new_non_basic_data_type_structure(object)
      structure = {}
      structure[:_id] = add_to_class_array(object) unless object.is_a?(Class) || object.is_a?(Module)
      structure.merge!(dump_class_variables(object))
      structure.merge!(dump_instance_variables(object))
      structure.merge!(dump_struct_member_values(object))
      structure
    end
    
    def dump_class_variables(object)
      structure = {}
      if object.respond_to?(:class_variables) && !object.class_variables.empty?
        structure[:_class_variables] = object.class_variables.reduce({}) do |class_vars, var|
          value = object.class_variable_get(var)
          class_vars.merge(var.to_s.sub('@@', '') => dump_structure(value))
        end
      end
      structure
    end
    
    def dump_instance_variables(object)
      structure = {}
      structure
      if !object.instance_variables.empty?
        structure[:_instance_variables] = object.instance_variables.reduce({}) do |instance_vars, var|
          value = object.instance_variable_get(var)
          instance_vars.merge(var.to_s.sub('@', '') => dump_structure(value))
        end
      end
      structure
    end
        
    def dump_struct_member_values(object)
      structure = {}
      if object.is_a?(Struct)
        structure[:_struct_member_values] = object.members.reduce({}) do |member_values, member|
          value = object[member]
          value.nil? ? member_values : member_values.merge(member => dump_structure(value))
        end
      end
      structure
    end
        
    private
    
    def top_level_class?(object, for_classes)
      (object.is_a?(Class) || object.is_a?(Module)) && !for_classes
    end
    
    def class_for(object)
      object.is_a?(Class) || object.is_a?(Module) ? object : object.class
    end
    
    def add_to_classes(object)
      classes << object unless classes.include?(object)
    end
    
    def object_id(object)
      object_class_array = class_objects[class_for(object)]
      object_class_array_index = object_class_array&.index(object)
      (object_class_array_index + 1) unless object_class_array_index.nil?
    end
    
    def add_to_class_array(object)
      object_class = class_for(object)
      class_objects[object_class] ||= []
      class_objects[object_class] << object unless class_objects[object_class].include?(object)
      class_objects[object_class].index(object) + 1
    end
        
  end
  
end
