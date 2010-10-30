module Lorenz
  module Node
    class Gem < Base
      params :name, :source
      version_param :version
      def create
        [cmd "gem install #{name} -v #{version}#{source ? ' --source' + source : ''}", "gem uninstall #{name} -v #{version}#{source ? ' --source' + source : ''}"]
      end

      def delete
        reverse_actions create
      end
      
      def set_param(param_name, from, to)
        case param_name
        when :source
          [
           cmd("gem uninstall #{path} -v #{version}", "gem install #{name} -v #{version}#{from ? ' --source' + from : ''}"),
           cmd("gem install #{name} -v #{version} --source #{source}", "gem uninstall #{name} -v #{version}#{to ? ' --source' + to : ''}")
          ]
        end
      end
      
      def id
        "#{name}-#{version}"
      end
      
      private
      
    end
  end
end