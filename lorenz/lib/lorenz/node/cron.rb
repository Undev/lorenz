module Lorenz
  module Node
    class Cron < Base
      params :command, :period, :user
      
      after_all_init do
        host.nodes(:cron).group_by { |v| v.user }.each do |user, crons|
          cron_tab = crons.map do |cron|
            "#{cron.period} #{cron.command}"
          end * "\n"
          execute "echo #{Shellwords.escape(cron_tab)} | crontab#{ user ? '-u ' + user : ''} -"
        end
      end
      def id
        "#{period}-#{command}"
      end
      
    end
  end
end