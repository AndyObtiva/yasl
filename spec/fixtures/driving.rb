module Driving
  class << self
    def set_var!
      @var = 'var value'
    end
    
    def reset_var!
      remove_instance_variable(:@var) if defined?(@var)
    end
  end
end
