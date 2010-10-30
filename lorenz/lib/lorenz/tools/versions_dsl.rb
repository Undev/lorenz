module Lorenz
  module Tools
    class VersionsDSL
      include Mixin::DSLLoad
      attr_accessor :current_package_type, :current_variant, :current_host
      attr_accessor :versions
      
      def initialize
        @versions = {}
      end
      
      def gems(&blk)
        var_context :current_package_type, Node::Gem, &blk
      end
      
      def packages(&blk)
        var_context :current_package_type, Node::Package, &blk
      end
      
      def variant(name, &blk)
        var_context :current_variant, name, &blk
      end
      
      def host(name, &blk)
        var_context :current_host, name, &blk
      end
      
      def var_context(var_name, value, &blk)
        old = send var_name
        self.send :"#{var_name}=", value
        instance_eval(&blk)
        self.send :"#{var_name}=", old
      end
      
      def gem(name, version)
        add_version :package_type => Node::Gem, 
                    :package_name => name, 
                    :variant => current_variant, 
                    :host => current_host, 
                    :version => version
      end
      
      def package(name, version)
        add_version :package_type => Node::Package, 
                    :package_name => name, 
                    :variant => current_variant, 
                    :host => current_host, 
                    :version => version
      end
      
      def method_missing(name, *args, &block)
        super unless current_package_type || args.first.blank?
        add_version :package_type => current_package_type, 
                    :package_name => name, 
                    :variant => current_variant, 
                    :host => current_host, 
                    :version => args.first
      end
      
      def add_version(params = {})
        package = "#{params[:package_type].name}-#{params[:package_name]}"
        key = if params[:variant] && params[:host]
          "#{params[:host]}-#{params[:variant]}-#{package}"
        elsif params[:variant]
          "variant-#{params[:variant]}-#{package}"
        elsif params[:host]
          "#{params[:host]}-#{package}"
        else
          package
        end
        versions[key] = params[:version]
        key
      end
      
      def setup
        Lorenz.versions = versions
      end
    end
  end  
end