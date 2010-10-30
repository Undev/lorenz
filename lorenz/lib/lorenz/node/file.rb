require 'shellwords'
module Lorenz
  module Node
    class File < Path
      params :content
      
      def create
        [cmd "touch #{path}", "rm #{path}"] +
        params.map do |k, v|
          set_param k, nil, v if v
        end.compact
      end

      def destroy
        [cmd "rm #{path}", "touch #{path}"]
      end
      
      def set_param(name, from, to)
        case name
        when :user
          cmd "chown #{to} #{path}", from ? "chown #{from} #{path}" : nil
        when :group
          cmd "chgrp #{to} #{path}", from ? "chgrp #{from} #{path}" : nil
        when :mode
          cmd "chmod #{to} #{path}", from ? "chmod #{from} #{path}" : nil
        when :content
          cmd "echo #{Shellwords.escape(to)} > #{path}", "echo #{Shellwords.escape(from || '')} > #{path}"
        end
      end

    end
  end
end