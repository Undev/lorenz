module Lorenz
  class DSL
  
    attr_accessor :host, :recipe, :parent
    def initialize(host, recipe = nil, parent = nil)
      @host = host
      @recipe = recipe
      @parent = parent
    end
  
    def define(&block)
      # puts "DEFINE!"
      # pp caller
      instance_eval(&block)
    end
    
    def self.define_node_method(node_class)
      class_eval <<-EOV
        def #{node_class.node_name}(params_or_arg = {}, params = {}, &block)
          params_or_arg ||= {}
          if params_or_arg.is_a?(Hash) 
            params.merge! params_or_arg
          else
            params[#{node_class.to_s}.params_list.first] = params_or_arg
          end
          new_node NodeDSL.new(#{node_class.to_s}, params, &block).to_node(host)
        end
      EOV
    end

    def include_recipe(name)
      raise "Undefined recipe #{name}" unless Lorenz[*name.to_s.split('::')]
      Lorenz[*name.to_s.split('::')].for_host host
    end
    
    def template(name, params = {})
      # TODO продумать нормальный find path для темплейтов
      recipe_name, template_name = if name.split('/').size > 1        
        name.split('/')
      else
        [recipe.name, name] if recipe
      end
      Template.new(recipe_name, template_name, params.blank? ? binding : params).to_s
    end
    
    def node(name, params, &block)
      return if Lorenz::Node.const_defined? "#{name.to_s.classify}"
      Lorenz::Node.const_set "#{name.to_s.classify}", Class.new(Node::Base)
      klass = "Lorenz::Node::#{name.to_s.classify}".constantize
      klass.params params
      klass.support_block = block
    end
  
    def new_node(node)
      return if host.node_exists? node
      # pp params
      # puts "New node #{node.key}"
      if parent
        node.parent = parent
        # puts "#{parent.id} << #{node.id}"
        parent.childs << node
      end
      [node.class.childs_block].compact.each do |block| #индивидуально для ноды определять чайлдов
        self.class.new(host, recipe, node).define(&block)
      end
      if node.class.after_all_init_block
        host.after_init_blocks[node.class] = node.class.after_all_init_block
      end
      host.node_list << node
      if node.class.after_init_block
        self.class.new(host, recipe, node).define(&node.class.after_init_block)
      end
      node
    end
  end
end