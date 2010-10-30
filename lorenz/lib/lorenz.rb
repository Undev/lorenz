require 'active_support/all'
require 'pathname'
require 'open4'
module Lorenz
  # Важно подгружать node после dsl
    
  %w{host state mixin/dsl_load dsl node node_list recipe action template converge delayed_action node_dsl tools/state tools/states_dsl tools/transition diff versions}.each do |f|
    # puts "lorenz/#{f}"
    require "lorenz/#{f}"
  end
  
  mattr_accessor :recipes_path, :recipes, :recipes_map
  mattr_accessor :versions

  class << self
    def reset
      @@recipes = []
      @@recipes_map = {}
      @@versions = Versions.new
    end
    
    def [](name, part = 'desc')
      recipes_map["#{name}::#{part}"]
    end
    
    def recipes_path=(val)
      @@recipes_path = val.is_a?(Pathname) ? val : Pathname(val)
    end
    
    def load(load_path = ENV['LORENZ_RECIPES_PATH'])
      self.recipes_path = load_path if load_path
      raise "Set recipes_path. Example: Lorenz.recipes_path = Pathname.new(File.dirname(__FILE__)) + 'recipes'. Or export LORENZ_RECIPES_PATH=path" unless recipes_path
      reset
      recipes_path.each_entry do |entry|
        if entry.to_s != '.' && entry.to_s != '..' && (recipes_path + entry).directory?
          recipe = initialize_recipe entry          
        end
      end
    end
    
    def set_versions(data = {})
      versions.data = data
    end
    
    def initialize_recipe(name, part = 'desc')
      return recipes_map["#{name}::#{part}"] if recipes_map["#{name}::#{part}"]
      recipes_map["#{name}::#{part}"] = :loading # FIXME хак для предотвращения бесконечных циклов с dependencies
      recipe = Recipe.new(recipes_path + name, part)
      recipes << recipe
      recipes_map["#{name}::#{part}"] = recipe
      recipe
    end
    # def load_recipe(name, part = 'desc')
    #   return recipes_map["#{name}-#{part}"] if recipes_map["#{name}-#{part}"]
    #   recipe = Recipe.new(recipes_path + name, part)
    #   recipe.load 
    #   recipes << recipe
    #   recipes_map["#{name}-#{part}"] = recipe    
    #   recipe
    # end
  end
end