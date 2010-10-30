include_recipe :ruby

gem "ohai"

collector :command => "ohai", :attribute_name => "ohai", :filter => proc { |res| ActiveSupport::JSON.decode res }