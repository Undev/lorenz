module Lorenz
  class Diff
    attr_accessor :from, :to
    attr_accessor :actions, :delayed_actions
    def initialize(from, to)
      @from, @to = from, to
      @actions, @delayed_actions = [], []
    end
    
    def nodes
      to.nodes
    end
    
    def nodes_map
      to.nodes_map
    end
    
    def perform
      nodes.each do |node|
        if from[node.key] && (diff = params_diff(node.params_list, from[node.key].params, node.all_params)).size > 0
          add :changed, node.perform_change(diff)
        elsif from[node.key].nil?
          add :create, node.perform_create
        end
      end

      minus_nodes.reverse.each do |node|
        add :destroy, node.perform_destroy
      end
      
      # TODO написать нормально
      actions.map { |v| v.node }.uniq.group_by { |v| v.parent }.each do |parent, nodes|
        if parent && !parent.new?
          add :childs_changed, parent.perform_childs_changed(nodes)
        end
      end
      actions + delayed_actions
    end
    
    private
    
    def add(type, new_actions)
      new_actions.each do |action|
        action.type = type
        case action
        when Action
          actions << action
        when DelayedAction
          delayed_actions << action
        end
      end
    end
    
    def params_diff(keys, h1, h2)
      # Важно, что бы keys всегда были в одном и том же порядке, иначе действия по их изменению смогут принимать различный порядок
      keys.inject(ActiveSupport::OrderedHash.new) do |res, k|
        unless h1[k] == h2[k]
          res[k] = [h1[k], h2[k]]
        end
        res
      end      
    end
    
    def minus_nodes
      from.nodes.select { |v| nodes_map[v.key].nil? }
    end
    
    # def exists_nodes
    #   from.nodes.select { |v| nodes_map[v.key] }
    # end
    
    # def changed_nodes(node_list)
    #   exists_nodes(node_list).inject([]) do |res, node|
    #     if (diff = node_list.nodes_map[v].params.diff(node.params)).size > 0
    #       res << [node, diff]
    #     end
    #     res
    #   end
    # end
    
    
  end
  
end