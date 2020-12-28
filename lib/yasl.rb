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

require 'json'
require 'date'
require 'set'

require 'yasl/dumper'
require 'yasl/loader'

module YASL
  JSON_BASIC_DATA_TYPES = [NilClass, String, Integer, Float, TrueClass, FalseClass]
  RUBY_ONLY_BASIC_DATA_TYPES = [Time, Date, Complex, Rational, Regexp, Symbol, Set, Range, Array, Hash]
  RUBY_BASIC_DATA_TYPES = RUBY_ONLY_BASIC_DATA_TYPES + JSON_BASIC_DATA_TYPES
  
  class << self
    def dump(object, include_classes: false)
      JSON.dump(Dumper.new(object).dump(include_classes: include_classes))
    end
    
    def load(data, include_classes: false)
      Loader.new(JSON.load(data)).load(include_classes: include_classes)
    end
    
    def json_basic_data_type?(object)
      type_in?(object, JSON_BASIC_DATA_TYPES)
    end
    
    def ruby_basic_data_type?(object)
      type_in?(object, RUBY_BASIC_DATA_TYPES)
    end
    
    private
    
    def type_in?(object, types)
      types.reduce(false) do |result, klass|
        result || object.is_a?(klass)
      end
    end
    
  end
end
