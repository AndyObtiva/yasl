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

Object.send(:remove_const, :Struct) if Object.constants.include?(:Struct)

# Optional re-implmentation of Struct in Pure Ruby (to get around JS issues in Opal Struct)
class Struct
  class << self
    CLASS_DEFINITION_FOR_ATTRIBUTES = lambda do |attributes, keyword_init|
      lambda do |defined_class|
        members_array = attributes
        
        define_method(:members) do
          members_array
        end
        
        def []=(attribute, value)
          normalized_attribute = attribute.to_s.to_sym
          raise NameError, "no member #{attribute} in struct" unless members.include?(normalized_attribute)
          @member_values[normalized_attribute] = value
        end
        
        def [](attribute)
          normalized_attribute = attribute.to_s.to_sym
          raise NameError, "no member #{attribute} in struct" unless members.include?(normalized_attribute)
          @member_values[normalized_attribute]
        end
        
        def each(&block)
          to_a.each(&block)
        end
        
        def each_pair(&block)
          @member_values.each_pair(&block)
        end
        
        def to_h
          @member_values.clone
        end
        
        def to_a
          @member_values.values
        end
        
        def size
          members.size
        end
        alias length size
        
        def dig(*args)
          @member_values.dig(*args)
        end
        
        def select(&block)
          to_a.select(&block)
        end
        
        def eql?(other)
          instance_of?(other.class) &&
            members.all? { |key| self[key].eql?(other[key]) }
        end
        
        def ==(other)
          other = coerce(other).first if respond_to?(:coerce, true)
          other.kind_of?(self.class) &&
            members.all? { |key| self[key] == other[key] }
        end
        
        def hash
          self.class.hash +
            to_a.each_with_index.map {|value, i| (i+1) * value.hash}.sum
        end
        
        if keyword_init
          def initialize(struct_class_keyword_args = {})
            @member_values = {}
            members.each do |attribute|
              singleton_class.define_method(attribute) do
                self[attribute]
              end
              singleton_class.define_method("#{attribute}=") do |value|
                self[attribute] = value
              end
            end
            struct_class_keyword_args.each do |attribute, value|
              self[attribute] = value
            end
          end
        else
          def initialize(*attribute_values)
            @member_values = {}
            members.each do |attribute|
              singleton_class.define_method(attribute) do
                self[attribute]
              end
              singleton_class.define_method("#{attribute}=") do |value|
                self[attribute] = value
              end
            end
            attribute_values.each_with_index do |value, i|
              attribute = members[i]
              self[attribute] = value
            end
          end
        end
      end
    end
    
    ARG_VALIDATION = lambda do |class_name_or_attribute, *attributes|
      class_name_or_attribute.nil? || attributes.any?(&:nil?)
    end
    
    CLASS_NAME_EXTRACTION = lambda do |class_name_or_attribute|
      if class_name_or_attribute.is_a?(String)
        raise NameError, "identifier name needs to be constant" unless class_name_or_attribute.match(/^[A-Z]/)
        class_name_or_attribute
      end
    end
    
    def new(class_name_or_attribute, *attributes, keyword_init: false)
      raise 'Arguments cannot be nil' if ARG_VALIDATION[class_name_or_attribute, *attributes]
      class_name = CLASS_NAME_EXTRACTION[class_name_or_attribute]
      attributes.unshift(class_name_or_attribute) if class_name.nil?
      attributes = attributes.map(&:to_sym)
      struct_class = Class.new(&CLASS_DEFINITION_FOR_ATTRIBUTES[attributes, keyword_init])
      class_name.nil? ? struct_class : const_set(class_name, struct_class)
    end
      
  end
end
