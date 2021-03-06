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
    attr_reader :structure, :whitelist_classes, :class_objects
    
    def initialize(structure, whitelist_classes: [])
      @structure = structure
      @whitelist_classes = whitelist_classes
      @class_objects = {}
    end
  
    def load(include_classes: false)
      load_structure(structure).tap do
        load_classes_structure if include_classes
      end
    end
    
    def load_classes_structure
      structure['_classes'].to_a.each do |class_structure|
        load_non_basic_data_type_object(class_structure, for_classes: true)
      end
    end
    
    def load_structure(structure, for_classes: false)
      if top_level_class?(structure)
        class_for(structure['_class'])
      elsif YASL.json_basic_data_type?(structure) && !(structure.is_a?(String) && structure.start_with?('_'))
        structure
      elsif ruby_basic_data_type_structure?(structure)
        load_ruby_basic_data_type_object(structure['_class'], structure['_data'])
      elsif load_non_basic_data_type_structure?(structure)
        load_non_basic_data_type_object(structure)
      end
    end
    
    private
    
    def ruby_basic_data_type_structure?(structure)
      (structure['_class'] && (structure['_data'] || !structure.keys.detect {|key| key.start_with?('_') && key != '_class'} ))
    end
    
    def load_non_basic_data_type_structure?(structure)
      structure['_class'] && (structure['_id'] || structure['_instance_variables'] || structure['_class_variables'] || structure['_struct_member_values'])
    end
    
    def load_non_basic_data_type_object(structure, for_classes: false)
      class_name = structure['_class']
      object_class = class_for(class_name)
      object_class.alias_method(:initialize_without_yasl, :initialize)
      object = object_for_id(object_class, structure['_id'])
      if object.nil?
        object = for_classes ? object_class : object_class.new
        add_to_class_array(object, structure['_id'])
      end
      structure['_class_variables'].to_a.each { |class_var, value| object.class_variable_set("@@#{class_var}".to_sym, load_structure(value)) }
      structure['_instance_variables'].to_a.each { |instance_var, value| object.instance_variable_set("@#{instance_var}".to_sym, load_structure(value)) }
      structure['_struct_member_values'].to_a.each { |member, value| load_struct_member_value(object, member, value) }
      object
    ensure
      object_class&.define_method(:initialize, object_class.instance_method(:initialize_without_yasl))
    end
    
    def load_ruby_basic_data_type_object(class_name, data)
      case class_name
      when 'Time'
        DateTime.new.marshal_load(data.map(&:to_r)).to_time
      when 'BigDecimal'
        BigDecimal(data)
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
        data.reduce({}) { |new_hash, pair| new_hash.merge(load_structure(pair.first) => load_structure(pair.last)) }
      end
    end
    
    private
    
    def class_for(class_name)
      class_name_components = class_name.to_s.split('::')
      current_class = Object
      object_class = class_name_components.reduce(Object) do |result_class, class_name|
        result_class.const_get(class_name)
      end
      if ![@whitelist_classes].compact.flatten.map(&:to_s).include?(object_class.to_s)
        raise "Class `#{class_name}` is not mentioned in `whitelist_classes` (e.g. `YASL.load(data, whitelist_classes: [#{class_name}])`)!"
      end
      object_class
    rescue NameError
      # TODO materialize a class matching the non-existing class
      raise "Class `#{class_name}` does not exist! YASL expects the same classes used for serialization to exist during deserialization."
    end
    
    def top_level_class?(structure)
      structure && structure.is_a?(Hash) && structure['_class'] && structure['_id'].nil? && structure['_instance_variables'].nil? && structure['_class_variables'].nil? && structure['_struct_member_values'].nil? && structure['_data'].nil?
    end
    
    def class_objects_for(object_class)
      class_objects[object_class] ||= {}
    end
    
    def object_for_id(object_class, class_object_id)
      return if class_object_id.nil?
      return unless (object_class.is_a?(Class) || object_class.is_a?(Module))
      class_objects_for(object_class)[class_object_id.to_i]
    end
    
    def add_to_class_array(object, class_object_id)
      return if object.is_a?(Class) || object.is_a?(Module) || class_object_id.nil?
      object_class = object.class
      found_object = object_for_id(object_class, class_object_id)
      class_objects_for(object_class)[class_object_id.to_i] = object unless found_object
    end
            
    def load_struct_member_value(object, member, value)
      value = load_structure(value)
      begin
        object[member.to_sym] = value
      rescue => e
        puts "#{e.message}. Setting `@#{member}` instance variable instead."
        object.instance_variable_set("@#{member}".to_sym, value)
      end
    end
  end
end
