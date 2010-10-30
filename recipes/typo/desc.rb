gem "bundler"

%w{libmysqlclient-dev libxml2-dev libxslt1-dev libsqlite3-dev mysql-server}.each do |name|
  package name
end

include_recipe :unicorn
unicorn_config :path => "/etc/unicorn/test.rb" do
  listen({ 3050 => '{ :tcp_nodelay => true, :backlog => 100 }' })
  worker_timeout 60
  preload_app 'false'
  before_fork 'sleep 1'
  worker_processes 1
end
deploy "/srv/typo", :url => "http://github.com/fdv/typo.git", :revision => 'master' do
  after_update do
    path = (parent.releases_path + parent.git_repo.sha).to_s
    execute "cd #{path} && cp config/database.yml.example config/database.yml"
    execute "cd #{path} && bundle install"
    execute "cd /srv/typo/shared/repo && cp config/database.yml.example config/database.yml"
    execute "cd /srv/typo/shared/repo && rake db:create"
    execute "cd #{path} && rake db:migrate"
  end
  
end  
runit_service :name => 'typo', :run_command => 'cd /srv/typo/current && unicorn_rails -c /etc/unicorn/test.rb', :hup_restart => true