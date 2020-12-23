require 'json'

module YASL
  class << self
    def dump(object)
      hash = {class: {}}
      hash[:class][:name] = object.class.name
      object.instance_variables.each do |var|
        hash[var.to_s.sub('@', '')] = object.instance_variable_get(var)
      end
      JSON.dump(hash)
    end
  end
end
