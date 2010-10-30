module Lorenz
  module Node
    class UnicornConfig < Base
      params :path, :listen, :working_directory, :worker_timeout, :preload_app, :worker_processes, :before_fork, :after_fork, :pid, :stderr_path, :stdout_path, :owner, :group, :mode
      
      childs do
        config_dir = ::File.dirname(parent.path)
        directory :path => config_dir
        p = parent
        file :path => parent.path, :content => template('unicorn/unicorn.rb', parent.all_params) do
          mode p.mode
          group p.group
          user p.owner        
        end
      end      
      
      def id
        path
      end
    end
  end
end