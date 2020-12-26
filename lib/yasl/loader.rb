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
    attr_reader :structure
    
    def initialize(structure)
      @structure = structure
    end
  
    def load
      load_structure(structure)
    end
    
    def load_structure(structure)
      if YASL.json_basic_data_type?(structure) && !(structure.is_a?(String) && structure.start_with?('_'))
        structure
      elsif structure['_data']
        load_ruby_basic_data_type(structure['_class'], structure['_data'])
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
    
#     def load_object(class_name, data: nil)
#       klass = class_for(class_name)
#       klass.alias_method(:initialize_without_yasl, :initialize)
#       object = klass.new
#       load_ruby_basic_data_type(object, data) unless data.nil?
#     ensure
#       klass.define_method(:initialize, klass.instance_method(:initialize_without_yasl))
#     end
    
    def load_ruby_basic_data_type(class_name, data)
      case class_name
#       when Time
#         object.to_datetime.marshal_dump
#       when Date
#         object.marshal_dump
#       when Complex, Rational, Regexp, Symbol
#         object.to_s
      when 'Symbol'
        data.to_sym
#       when Set
#         object.to_a
#       when Range
#         [object.begin, object.end, object.exclude_end?]
      when 'Array'
        data.map {|element| load_structure(element)}
      when 'Hash'
        data.reduce({}) do |new_hash, pair|
          new_hash.merge(load_structure(pair.first) => load_structure(pair.last))
        end
      end
    end
  end
end
