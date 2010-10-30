module Lorenz
  module Node
    class Deploy < Base
      params :path, :url, :shared_symlinks, :revision, :after_update
      attr_accessor :git_repo
      childs do
        directory parent.path
        directory parent.releases_path.to_s
        directory parent.shared_path.to_s
        parent.git_repo = git parent.repo_path.to_s, :url => parent.url, :revision => parent.revision
        
        directory :path => (parent.releases_path + parent.git_repo.sha).to_s, :copy => parent.repo_path.to_s
        if parent.after_update
          instance_eval(&parent.after_update)
        end
        if parent.shared_symlinks
          shared_symlinks.each do |from, to|
            directory :path => (parent.shared_path + to.to_s).to_s
            ln :to => (parent.shared_path + to).to_s, :from => from.to_s
          end
        end
        ln :to => (parent.releases_path + parent.git_repo.sha).to_s, :from => parent.current_path.to_s
      end
      
      def pathname
        Pathname.new path
      end
      
      def shared_path
        pathname + 'shared'
      end
      
      def current_path
        pathname + 'current'
      end
      
      def release_path
        releases_path + git_repo.sha
      end
      
      def releases_path
        pathname + 'releases'
      end
      
      def repo_path
        shared_path + 'repo'
      end
      
      def create
        []
      end
      
      def destroy
        []
      end
      
      # def childs_changed(nodes = [])
      #   after_deploy ? [cmd after_deploy] : []
      # end
      
      def sha
        git_repo.sha
      end
      
      def id
        path
      end
      
    end
  end
end