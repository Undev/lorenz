module Lorenz
  module Node
    class Ln < Base
      params :from, :to
      
      def create
        [cmd "ln -f -s #{to} #{from}", "rm #{from}"]
      end
      
      def destroy
        reverse_actions create
      end
      
      def set_param(name, from_param, to_param)
        case name
        when :to
          cmd "ln -f -s #{to_param} #{from}", "ln -f -s #{from_param} #{from}"
        end
      end
      
      def id
        from
      end

    end
  end
end