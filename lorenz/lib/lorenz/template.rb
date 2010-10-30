module Lorenz
  class Template
    attr_accessor :recipe_name, :name, :context, :params
    def initialize(recipe_name, name, context_or_params = {})
      @recipe_name, @name = recipe_name, name
      if context_or_params.is_a? Hash
        @params = context_or_params
      else
        @context = context_or_params
      end
    end
    
    def to_s
      ERB.new((Lorenz.recipes_path + recipe_name + 'templates' + "#{name}.erb").read).result context ? context : binding
    end    
    
  end
end