module Lorenz
  module Tools
    class Transition
      attr_accessor :from, :to
      attr_accessor :assert_actions
      def initialize(from, to, &blk)
        @from, @to = from, to
        @assert_actions = []
        instance_eval(&blk) if blk
      end
    
      def a(str)
        assert_actions << str
      end
    
      def assert
      
      end
    
      def run
        host = dummy_host
        from.compile host
        host.apply_callbacks
        host.converged
        to.compile host
        host.apply_callbacks
        host.diff
      end
      
      def run_and_assert
        actions = run.map(&:command)
        if actions == assert_actions
          [true]
        else
          [false, { :expected => assert_actions, :actions => actions, :plus => actions - assert_actions, :minus => assert_actions - actions }] # Не покажет ничего наглядного при неправильном порядке действий
        end
      end
    
      def dummy_host(name = "host")
        host = Host.new :ip => '127.0.0.1', :ssh_user => 'root', :name => name        
      end
    end
  end
end