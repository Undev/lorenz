module Lorenz
  class Recipe::MetaDSL
    attr_accessor :params
    def initialize
      @params = {}
    end
  
    def define(&block)
      instance_eval(&block)
    end
  
    def name(name)
      params[:name] = name
    end
    
    def dependencies(*recipes)
      params[:dependencies] = recipes
    end
  end
end