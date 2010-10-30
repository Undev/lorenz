module Lorenz
  class Host
    attr_accessor :recipes, :options
    attr_accessor :node_list, :after_init_blocks
    attr_accessor :current_state, :attributes
    def initialize(options = {})
      @recipes = options[:recipes] || []
      # @current_state = State.new(options[:current_states] || [])
      @current_state = options[:current_state] || NodeList.from_states(options[:current_states] || [], self)
      @node_list, @after_init_blocks = NodeList.new, {}
      @attributes = options[:attributes] || {}
      @options = options
    end
    
    def apply_recipes
      recipes.each { |v| v.for_host(self) }
      apply_callbacks
    end
    
    def apply_callbacks
      after_init_blocks.each do |type, block|
        DSL.new(self).define(&block)
      end
    end
    
    def nodes(type)
      node_list.nodes.select { |v| v.class.node_name == type.to_s}
    end
    
    def node_exists?(node)
      node_list.nodes_map[node.key].present?
    end
    
    def diff       
      actions = node_list.converge_actions current_state
      actions.map { |v| v.node.class }.uniq.each do |action_class|
        if action_class.respond_to?(:one_time_actions)
          # FIXME здесь передавать ноду от тех экшенов что вызвали one_time_actions
          actions = action_class.one_time_actions(actions.first.node) + actions
        end
      end
      actions
    end

    def converged
      self.current_state = node_list.dup
      self.node_list = NodeList.new
    end

    def reset!
      self.current_state = NodeList.new
    end
  end
end