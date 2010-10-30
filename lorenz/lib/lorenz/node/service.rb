module Lorenz
  module Node
    class Service < Base
      params :name, :start_command, :stop_command, :restart_command
      
      def create
        [cmd start_command, stop_command]
      end
      
      def destroy
        reverse_actions create
      end
      
      def childs_changed(nodes = [])
        [cmd restart_command]
      end
      
      def set_param(param_name, from, to)
        case param_name
        when :start_command
          [cmd(stop_command),
           cmd(to)]
        when :restart_command
         [cmd(stop_command),
          cmd(to)]
        end
      end
      
      def id
        name
      end
      
    end
  end
end