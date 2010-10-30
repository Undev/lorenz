module Lorenz
  class NodeDSL
    attr_accessor :node_class, :params, :childs_block
    def initialize(node_class, params = {}, &block)
      @node_class = node_class
      @params = params
      instance_eval(&block) if block
    end
    
    def childs(&block)
      @childs_block = block
    end
    
    def to_node(host)
      node_class.new params, host
    end
    
    # TODO добавить хороший raise при неправильном использовании
    def method_missing(name, *args, &blk)
      params[name] = blk || args.first
    end
  end
end