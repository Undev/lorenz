namespace :lorenz do
  desc "Converge all hosts"
  task :converge => :environment do
    Host.all.select { |v| v.diff.size > 0 }.each do |host|
      host.perform_converge
    end
  end
end