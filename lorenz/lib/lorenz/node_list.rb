module Lorenz
  class NodeList

    class << self
      def load(path, host)
        deserialize ::File.read(path), host
      end
      
      def from_states(states, host)
        node_list = self.new
        states.each do |raw_node|
          node_list << raw_node['type'].constantize.new(raw_node['params'], host)
        end
        node_list
      end
      
      def deserialize(string, host)
        from_states ActiveSupport::JSON.decode(string), host
      end

    end
  
    attr_accessor :nodes, :nodes_map
  
    def initialize()
      @nodes = []
      @nodes_map = {}
    end
  
    def <<(node)
      unless nodes_map[node.key]
        nodes << node
        nodes_map[node.key] = node
      end
    end
    
    def [](key)
      nodes_map[key]
    end
  
    
    # def converge(node_list)
    #   {
    #    :plus_nodes => plus_nodes(node_list),
    #    :minus_nodes => minus_nodes(node_list),
    #    :changed_nodes => changed_nodes(node_list)
    #   }
    # end
    
    # Возвращает diff необходимых действий
    def converge_actions(from_state)
      Diff.new(from_state, self).perform
    end
    
    # def +(node_list)
    #   new_node_list = self.class.new
    #   (nodes + plus_nodes(node_list)).each do |node| 
    #     new_node_list << node
    #   end
    #   new_node_list
    # end
    
    def serialize
      nodes.map(&:serialize)
    end
  
    def print
      nodes.each do |node|
        pp node.params
      end
    end
  
    def save(path)
      ::File.open(path, 'w') { |f| f.puts ActiveSupport::JSON.encode(serialize) }
    end

  end
end