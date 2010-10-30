require 'digest/sha1'

module Lorenz
  module Node
    class Execute < Base
      params :command, :rollback, :lang
      
      childs do
        if parent.lang
          directory "/tmp/lorenz"
          directory "/tmp/lorenz/executes"
          file parent.command_file, :content => parent.command
          file parent.rollaback_file, :content => parent.rollback if parent.rollback
        end
      end
      
      def create
        [cmd command_line, rollback ? rollback_line : nil]
      end
      
      def destroy
        rollback ? [cmd rollback_line, command_line] : []
      end

      # FIXME нельзя делать create тут
      # def dependencies_changed(nodes = [])
      #   create
      # end
      
      def command_file
        "/tmp/lorenz/executes/#{Digest::SHA1.hexdigest(command)}.#{lang}"
      end
      
      def rollaback_file
        "/tmp/lorenz/executes/#{Digest::SHA1.hexdigest(command)}.#{lang}.rollback"
      end
      
      def command_line
        case lang
        when :ruby
          "ruby #{command_file}"
        else
          command          
        end
      end
      
      def rollback_line
        case lang
        when :ruby
          "ruby #{rollaback_file}"
        else
          rollback          
        end
      end
    
      def id
        command
      end
      
    end
  end
end