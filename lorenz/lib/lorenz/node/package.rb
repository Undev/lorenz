module Lorenz
  module Node
    class Package < Base
      params :name
      version_param :version

      def self.one_time_actions(node)
        [cmd "apt-get update", nil, node]
      end
      
      def create
        [cmd "apt-get -q -y install #{name}=#{version}", "apt-get -q -y remove #{name}=#{version}"]
      end

      def delete
        reverse_actions create
      end
      
      def set_param(param_name, from, to)
        case param_name
        when :version
          cmd "apt-get -q -y install #{name}=#{to}", "apt-get -q -y install #{name}=#{from}"
        end
      end
      
      def id
        name
      end

    end
  end
end