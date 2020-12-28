module Driving
  class Person
    class << self
      def reset_count!
        @count = 0
      end
      
      def increment_count!
        @count ||= 0
        @count += 1
      end
      
      def count
        @count
      end
      
      def reset_class_count!
        @@class_count = 0
      end
      
      def increment_class_count!
        @@class_count = 0 unless defined?(@@class_count)
        @@class_count += 1
      end
      
      def class_count
        @@class_count
      end
      
    end
    
    ATTRIBUTES = [:name, :dob, :cars]
    attr_accessor *ATTRIBUTES
    include Equalizer.new(*ATTRIBUTES)
    
    def initialize
      self.class.increment_count!
      self.class.increment_class_count!
    end
  end
end
