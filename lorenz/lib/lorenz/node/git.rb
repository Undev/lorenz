module Lorenz
  module Node
    class Git < Directory
      params :url, :revision
      node_params :sha
      
      # set_callback :init, :before do
      #   package "git-core", :version => '1:1.5.6.5-3+lenny3.1'
      # end
      
      childs do
        package "git-core"
      end
      
      def initialize(*args)
        super(*args)
        unless self.sha
          result = `git ls-remote #{url} #{revision}`
          # self.init_actions << cmd("git ls-remote #{url} #{revision}") do |result|
          revdata = result.split(/[\t\n]/)
          newrev = nil
          revdata.each_slice(2) do |refs|
            rev, ref = *refs
            if ref.sub(/refs\/.*?\//, '').strip == revision.to_s
              newrev = rev
              break
            end
          end
          raise "Undefined sha for #{url} and #{revision}" unless newrev
          self.sha = newrev
          # end
        end
      end

      def create
        [cmd("git clone --depth 0 #{url} #{path} && cd #{path} && git checkout #{sha}", "rm -R #{path}"),
         cmd("cd #{path} && git submodule update --init")] + init_params
      end
      
      def set_param(param_name, from, to)
        case param_name
        when :sha
          cmd "cd #{path} && git fetch && git checkout #{to} && git submodule update", 
              "cd #{path} && git fetch && git checkout #{from} && git submodule update"
        else
          super
        end
      end
      
      def id
        "#{path}-#{url}-#{revision}"
      end

    end
  end
end