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
  class Loader
    attr_reader :structure, :classes, :class_objects
    
    def initialize(structure)
      @structure = structure
      @classes = []
      @class_objects = {}
    end
  
    def load(include_classes: false)
      load_structure(structure).tap do
        load_classes_structure if include_classes
      end
    end
    
    def load_classes_structure
      structure['_classes'].each do |class_structure|
        load_non_basic_data_type_object(class_structure, for_classes: true)
      end
    end
    
    def load_structure(structure, for_classes: false)
      if YASL.json_basic_data_type?(structure) && !(structure.is_a?(String) && structure.start_with?('_'))
        structure
      elsif (structure['_class'] && (structure['_data'] || !structure.keys.detect {|key| key.start_with?('_') && key != '_class'} ))
        load_ruby_basic_data_type_object(structure['_class'], structure['_data'])
      elsif structure['_class'] && (structure['_instance_variables'] || structure['_class_variables'] || structure['_struct_member_values'])
        load_non_basic_data_type_object(structure)
      end
    end
    
    private
    
    def load_non_basic_data_type_object(structure, for_classes: false)
      class_name = structure['_class']
      klass = class_for(class_name)
      add_to_classes(klass)
      klass.alias_method(:initialize_without_yasl, :initialize)
      object = for_classes ? klass : klass.new
      add_to_class_array(object) if !object.is_a?(Class) && !object.is_a?(Module)
      structure['_instance_variables'].to_a.each do |instance_var, value|
        value = load_structure(value)
        object.instance_variable_set("@#{instance_var}".to_sym, value)
      end
      structure['_struct_member_values'].to_a.each do |member, value|
        value = load_structure(value)
        object[member.to_sym] = value
      end
      if for_classes
        structure['_class_variables'].to_a.each do |class_var, value|
          value = load_structure(value)
          object.class_variable_set("@@#{class_var}".to_sym, value)
        end
      end
      object
    ensure
      klass.define_method(:initialize, klass.instance_method(:initialize_without_yasl))
    end
    
    def load_ruby_basic_data_type_object(class_name, data)
      case class_name
      when 'Time'
        DateTime.new.marshal_load(data.map(&:to_r)).to_time
      when 'Date'
        Date.new.marshal_load(data.map(&:to_r))
      when 'DateTime'
        DateTime.new.marshal_load(data.map(&:to_r))
      when 'Complex'
        Complex(data)
      when 'Rational'
        Rational(data)
      when 'Regexp'
        Regexp.new(data)
      when 'Symbol'
        data.to_sym
      when 'Set'
        Set.new(data.map {|element| load_structure(element)})
      when 'Range'
        Range.new(*data)
      when 'Array'
        data.map {|element| load_structure(element)}
      when 'Hash'
        data.reduce({}) do |new_hash, pair|
          new_hash.merge(load_structure(pair.first) => load_structure(pair.last))
        end
      else
        class_for(class_name)
      end
    end
    
    private
    
    def class_for(class_name)
      class_name_components = class_name.split('::')
      current_class = Object
      class_name_components.reduce(Object) do |result_class, class_name|
        result_class.const_get(class_name)
      end
    rescue => e
      # TODO materialize a class matching the non-existing class
      puts "Class #{class_name} does not exist! YASL expects the same classes used for serialization to exist during deserialization."
    end
    
#     def top_level_class?(object, for_classes)
#       (object.is_a?(Class) || object.is_a?(Module)) && !for_classes
#     end
    
    def add_to_classes(object)
      classes << object unless classes.include?(object)
    end
    
#     def class_object_id(object)
#       object_class_array = class_objects[class_for(object)]
#       object_class_array_index = object_class_array&.index(object)
#       (object_class_array_index + 1) unless object_class_array_index.nil?
#     end
    
#     def object_for_id(klass, klass_object_id)
#       object_class_array = class_objects[klass]
#       object_class_array&.[](klass_object_id - 1)
#     end
    
    def add_to_class_array(object)
#       return if object.is_a?(Class) # TODO enable if needed or remove
      object_class = object.class
      class_objects[object_class] ||= []
      class_objects[object_class] << object unless class_objects[object_class].include?(object)
      class_objects[object_class].index(object) + 1
    end
            
  end
end
