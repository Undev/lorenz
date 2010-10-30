module Lorenz
  module Node
    class RunitService < Base
      params :name, :run_command, :hup_restart, :log_content, :run_content, :finish_content, :control, :files, :urls, :allowed_signals
      
      # set_callback :init, :before do
      childs do
        include_recipe :runit
        sv_dir_name = "/etc/sv/#{parent.params[:name]}"
        directory :path => sv_dir_name
        directory :path => "#{sv_dir_name}/log"
        file :path => "#{sv_dir_name}/run", :mode => "+x", :content => parent.run_content || template('runit/run')
        if parent.finish_content
          file :path => "#{sv_dir_name}/finish", :mode => "+x", :content => parent.finish_content
        end
        file :path => "#{sv_dir_name}/log/run", :mode => "+x", :content => parent.log_content || template('runit/log_run')
        
        unless parent.control.blank?
          directory :path => "#{sv_dir_name}/control", :mode => "0755"

          parent.control.each do |signal_name, content|
            file "#{sv_dir_name}/control/#{signal_name}", :mode => "0755", :content => content
          end
        end
        
        unless parent.files.blank?
          directory "#{sv_dir_name}/runit-man/files-to-view", :mode => "0755"

          parent.files.each do |f|
            ln :to => f, :from => "#{sv_dir_name}/runit-man/files-to-view/#{f.gsub('/', '_')}"
          end
        end

        unless parent.urls.blank?
          directory "#{sv_dir_name}/runit-man/urls-to-view", :mode => "0755"

          parent.urls.each do |f|
            file "#{sv_dir_name}/runit-man/urls-to-view/#{f.gsub(/[\:\/\?\&\=]/, '_')}.url", :content => f
          end
        end

        unless parent.allowed_signals.blank?
          directory "#{sv_dir_name}/runit-man/allowed-signals", :mode => "0755"

          parent.allowed_signals.each do |signal|
            file "#{sv_dir_name}/runit-man/allowed-signals/#{signal}", :mode => "0644"
          end
        end        
        
        ln :to => "/etc/sv/#{parent.name}/", :from => "/etc/service/#{parent.name}"
        execute :lang => :ruby, :command => template('runit/supervise_sleep.rb', :sv_dir_name => sv_dir_name)
        
        service :name => parent.name, :start_command => "sv start #{parent.name}", :stop_command => "sv stop #{parent.name} || echo \"Unable to stop service\"", :restart_command => "sv #{parent.hup_restart ? 'hup' : 'restart'} #{parent.name} || \"Unable to restart service\""
      end
      
      def childs_changed(nodes = [])
        # puts "dependencies_changed!!!"
        # TODO Определиться node_name str или sym
        # require 'ruby-debug'
        # debugger
        childs.select { |v| v.class.node_name == 'service' }.map { |v| cmd v.restart_command }
      end
      
      def set_param(param_name, from, to)
        []
      end
      
      def id
        name
      end
    end
  end
end