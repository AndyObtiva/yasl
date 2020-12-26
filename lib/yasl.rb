require 'json'
require 'date'

require 'yasl/dumper'

module YASL
  JSON_BASIC_DATA_TYPES = [NilClass, String, Integer, Float, TrueClass, FalseClass]
  RUBY_ONLY_BASIC_DATA_TYPES = [Time, Date, Complex, Rational, Regexp, Symbol, Set, Range, Array, Hash]
  RUBY_BASIC_DATA_TYPES = RUBY_ONLY_BASIC_DATA_TYPES + JSON_BASIC_DATA_TYPES
  
  class << self
    def dump(object, include_classes: true)
      JSON.dump(Dumper.new(object).dump(include_classes: include_classes))
    end
    
    def load(data)
      # TODO alias initialize on every class loaded to bypass argument requirements
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
