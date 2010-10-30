module Lorenz
  module Tools
    class StatesDSL
      include Mixin::DSLLoad
      attr_accessor :states, :transitions
      
      def initialize
        @states, @transitions = {}, {}
      end
      
      def state(name, &blk)
        states[name.to_s] = State.new(name.to_s, &blk)
      end
      
      def diff(from, to)
        Transition.new(states[from], states[to]).run
      end
      
      def transition(directions = {}, &blk)
        from, to = directions.first
        transitions[from.to_s + to.to_s] = Transition.new(states[from.to_s], states[to.to_s], &blk)
      end
    end
  end  
end