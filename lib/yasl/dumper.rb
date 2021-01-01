# Copyright (c) 2020 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module YASL
  class Dumper
    attr_reader :object, :classes, :class_objects
    
    def initialize(object)
      @object = object
      @classes = []
      @class_objects = {}
    end
    
    def dump(include_classes: false)
      structure = dump_structure(object)
      structure.merge!(dump_classes_structure) if include_classes && structure.is_a?(Hash)
      structure
    end
    
    def dump_structure(object, for_classes: false)
      return if unserializable?(object)
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
    
    def dump_classes_structure
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
    
    def dump_ruby_basic_data_type_data(obj)
      class_ancestors_names_include = lambda do |*class_names|
        lambda { |obj| class_names.any? { |class_name| obj.class.ancestors.map(&:name).include?(class_name) } }
      end
      case obj
      when class_ancestors_names_include['Time']
        obj.to_datetime.marshal_dump
      when class_ancestors_names_include['Date']
        obj.marshal_dump
      when class_ancestors_names_include['Complex', 'Rational', 'Regexp', 'Symbol', 'BigDecimal']
        obj.to_s
      when class_ancestors_names_include['Set']
        obj.to_a.uniq.map {|element| dump_structure(element)}
      when class_ancestors_names_include['Range']
        [obj.begin, obj.end, obj.exclude_end?]
      when class_ancestors_names_include['Array']
        obj.map {|element| dump_structure(element)}
      when class_ancestors_names_include['Hash']
        obj.reject do |key, value|
          [key, value].detect {|element| unserializable?(element)}
        end.map do |pair|
          pair.map {|element| dump_structure(element)}
        end
      end
    end
    
    def dump_non_basic_data_type_structure(object)
      structure = {}
      klass = class_for(object)
      add_to_classes(klass)
      structure[:_class] = klass.name
      the_class_object_id = class_object_id(object)
      if the_class_object_id.nil?
        structure.merge!(dump_new_non_basic_data_type_structure(object))
      else
        structure[:_id] = the_class_object_id
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
        structure[:_class_variables] = dump_class_variables_hash(object)
        structure.delete(:_class_variables) if structure[:_class_variables].empty?
      end
      structure
    end
    
    def dump_instance_variables(object)
      structure = {}
      if !object.instance_variables.empty?
        structure[:_instance_variables] = dump_instance_variables_hash(object)
        structure.delete(:_instance_variables) if structure[:_instance_variables].empty?
      end
      structure
    end
        
    def dump_struct_member_values(object)
      structure = {}
      if object.is_a?(Struct)
        structure[:_struct_member_values] = dump_struct_member_values_hash(object)
        structure.delete(:_struct_member_values) if structure[:_struct_member_values].empty?
      end
      structure
    end
    
    def unserializable?(value)
      result = UNSERIALIZABLE_DATA_TYPES.detect {|class_name| value.class.ancestors.map(&:name).include?(class_name.to_s)}
      result = ((value.is_a?(Class) || value.is_a?(Module)) && value.name.nil?) if result.nil?
      result
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
    
    def class_object_id(object)
      object_class_array = class_objects[class_for(object)]
      object_class_array_index = object_class_array&.index(object)
      (object_class_array_index + 1) unless object_class_array_index.nil?
    end
    
    def dump_class_variables_hash(object)
      object.class_variables.reduce({}) do |class_vars, var|
        value = object.class_variable_get(var)
        unserializable?(value) ? class_vars : class_vars.merge(var.to_s.sub('@@', '') => dump_structure(value))
      end
    end
    
    def dump_instance_variables_hash(object)
      object.instance_variables.sort.reduce({}) do |instance_vars, var|
        value = object.instance_variable_get(var)
        unserializable?(value) ? instance_vars : instance_vars.merge(var.to_s.sub('@', '') => dump_structure(value))
      end
    end
    
    def dump_struct_member_values_hash(object)
      object.members.reduce({}) do |member_values, member|
        value = object[member]
        value.nil? || unserializable?(value) ? member_values : member_values.merge(member => dump_structure(value))
      end
    end
    
    def add_to_class_array(object)
      object_class = class_for(object)
      class_objects[object_class] ||= []
      class_objects[object_class] << object unless class_objects[object_class].include?(object)
      class_objects[object_class].index(object) + 1
    end
        
  end
  
end
