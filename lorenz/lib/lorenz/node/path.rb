module Lorenz
  module Node
    class Path < Base
      params :path, :user, :group, :mode

      def id
        path
      end

    end
  end
end