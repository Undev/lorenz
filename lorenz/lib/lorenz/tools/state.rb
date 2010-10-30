module Lorenz
  module Tools
    class State
      attr_accessor :name, :blk
      attr_accessor :node_list    
      def initialize(name, &blk)
        @name, @blk = name, blk
      end
      
      def compile(host)
        dsl = DSL.new host
        dsl.define(&blk)
        host.node_list
      end
    end
  end
end