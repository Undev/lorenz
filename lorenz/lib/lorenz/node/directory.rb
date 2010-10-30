module Lorenz
  module Node
    class Directory < Path
      params :recursive, :copy
      def create
        # [cmd "mkdir#{recursive ? ' -p' : ''} #{path}"] +
        create_main + init_params

      end
      
      def init_params
        params.map do |k, v|
          set_param k, nil, v if v
        end.compact
      end
      
      def create_main
        if copy
          [cmd "cp -R #{copy} #{path}", "rm -R #{path}"]
        else
          [cmd "mkdir -p #{path}", "rm -R #{path}"]        
        end
      end

      def destroy
        reverse_actions create_main # rollback команда охуенна, да
      end
      
      def set_param(name, from, to)
        case name
        when :user
          cmd "chown#{recursive ? ' -R' : ''} #{to} #{path}", from ? "chown#{recursive ? ' -R' : ''} #{from} #{path}" : nil
        when :group
          cmd "chgrp#{recursive ? ' -R' : ''} #{to} #{path}", from ? "chgrp#{recursive ? ' -R' : ''} #{from} #{path}" : nil
        when :mode
          cmd "chmod#{recursive ? ' -R' : ''} #{to} #{path}", from ? "chmod#{recursive ? ' -R' : ''} #{from} #{path}" : nil
        end
      end
      
    end
  end
end