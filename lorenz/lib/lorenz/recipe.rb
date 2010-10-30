module Lorenz
  class Recipe
    require 'lorenz/recipe/meta_dsl'
    attr_accessor :name, :path, :part
    def initialize(path, part)
      @path, @part = path, part
      @name = path.basename.to_s
      load_meta
      load_nodes
    end
    
    def load_nodes
      nodes_path = (path + 'nodes.rb')
      return unless nodes_path.exist?
      require nodes_path.to_s
    end
    
    def load_meta
      meta_path = (path + 'meta.rb')
      return unless meta_path.exist?
      dsl = MetaDSL.new
      dsl.define do
        instance_eval(meta_path.read, meta_path.to_s)
      end
      self.name = dsl.params[:name] if dsl.params[:name]
      if dsl.params[:dependencies]
        dsl.params[:dependencies].each do |recipe_name|
          Lorenz.initialize_recipe(*recipe_name.split('::'))
        end
      end
    end
    
    # def load_desc
    #   dsl = DSL.new self
    #   desc_path = (path + "#{part}.rb")
    #   dsl.define do
    #     instance_eval(desc_path.read, desc_path.to_s)
    #   end
    # end
    
    def for_host(host)
      dsl = DSL.new host, self
      desc_path = (path + "#{part}.rb")
      dsl.define do
        instance_eval(desc_path.read, desc_path.to_s)
      end
    end
    
    # def load
    #   load_meta
    #   load_nodes
    #   load_desc
    # end
  end
end