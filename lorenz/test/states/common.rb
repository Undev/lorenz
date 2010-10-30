# def with_versions(new_versions = {}, &blk)
#   old = Lorenz.versions.data
#   Lorenz.versions.data = new_versions
#   blk.call
#   Lorenz.versions.data = old
# end

state :empty do
  
end

state :test1 do
  file "/tmp/t.txt", :content => 'Hello world'  
  include_recipe :runit
  runit_service :name => "test_service", :run_command => "sleep 700"
  # runit_service :name => "test_service", :run_command => "sleep 700"
end

state :test2 do
  file :path => "/tmp/t2.txt", :content => ':)'
  file :path => "/tmp/t3.txt", :content => 'blo!'
  include_recipe :runit
  runit_service :name => "test_service", :run_command => "sleep 300"
end

state :version_test1 do
  Lorenz.versions.data = { 'Lorenz::Node::Package-git' => '1.5'}
  package "git"
end

state :version_test2 do
  Lorenz.versions.data = { 
    'Lorenz::Node::Package-git' => '1.5',
    'variant-1.6-Lorenz::Node::Package-git' => '1.6'
  }
  package "git", :version => :"1.6"
end

state :version_test3 do
  Lorenz.versions.data = { 
    'Lorenz::Node::Package-git' => '1.5',
    'variant-1.6-Lorenz::Node::Package-git' => '1.6',
    'host-Lorenz::Node::Package-git' => '1.7'
  }
  package "git"
end

state :version_test4 do
  Lorenz.versions.data = { 
    'Lorenz::Node::Package-git' => '1.5',
    'variant-1.6-Lorenz::Node::Package-git' => '1.6',
    'host-Lorenz::Node::Package-git' => '1.7',
    'host-1.6-Lorenz::Node::Package-git' => '1.8'
  }
  package "git", :version => :"1.6"
end

state :version_test5 do
  Lorenz.versions.data = { 
    'Lorenz::Node::Package-git' => '1.5',
    'variant-1.6-Lorenz::Node::Package-git' => '1.6',
    'host-Lorenz::Node::Package-git' => '1.7',
    'host-1.6-Lorenz::Node::Package-git' => '1.8'
  }
  package "git", :version => "2.0"
end

state :ohai do
  include_recipe :ohai
end

state :unicorn do
  include_recipe :unicorn
  unicorn_config :path => "/etc/unicorn/test.rb" do
    listen({ 3050 => '{ :tcp_nodelay => true, :backlog => 100 }' })
    worker_timeout 60
    before_fork 'sleep 1'
  end
  deploy "/srv/typo", :url => "http://github.com/fdv/typo.git", :revision => 'master' do
    after_update do
      path = (parent.releases_path + parent.git_repo.sha).to_s
      execute "cd /srv/typo/shared/repo && rake db:create"
      execute "cd #{path} && rake db:migrate"
    end
    
  end  
  runit_service :name => 'typo', :run_command => 'unicorn_rails -c /etc/unicorn/test.rb', :hup_restart => true
end

transition :empty => :test1 do
a 'apt-get update'
a 'touch /tmp/t.txt'
a 'echo Hello\ world > /tmp/t.txt'
a 'apt-get -q -y install runit=1.4'
a 'mkdir -p /etc/sv/test_service'
a 'mkdir -p /etc/sv/test_service/log'
a 'touch /etc/sv/test_service/run'
a 'chmod +x /etc/sv/test_service/run'
a %q{echo \#\!/bin/sh'
'exec\ 2\>\&1'
''
'sleep\ 700 > /etc/sv/test_service/run}
a 'touch /etc/sv/test_service/log/run'
a 'chmod +x /etc/sv/test_service/log/run'
a %q{echo \#\!/bin/sh'
''
'\#\ store\ logs\ in\ /storage/log\ if\ possible\ \(zombie\ convention\)'
'LOG_FOLDER\=/var/log/test_service'
'if\ \[\ -d\ /storage\ \]\;\ then'
'\ \ \ \ LOG_FOLDER\=/storage/log/test_service'
'fi'
''
'mkdir\ -p\ \$LOG_FOLDER'
'exec\ svlogd\ -tt\ \$LOG_FOLDER > /etc/sv/test_service/log/run}
a 'ln -f -s /etc/sv/test_service/ /etc/service/test_service'
a 'mkdir -p /tmp/lorenz'
a 'mkdir -p /tmp/lorenz/executes'
a 'touch /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
a 'echo \(1..20\).each\ \{\|i\|\ sleep\ 1\ unless\ ::FileTest.pipe\?\(\"/etc/sv/test_service/supervise/ok\"\)\ \} > /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
a 'ruby /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
a 'sv start test_service'
end

transition :test1 => :test2 do
  a 'touch /tmp/t2.txt'
  a 'echo :\) > /tmp/t2.txt'
  a 'touch /tmp/t3.txt'
  a 'echo blo\! > /tmp/t3.txt'
  a %q{echo \#\!/bin/sh'
'exec\ 2\>\&1'
''
'sleep\ 300 > /etc/sv/test_service/run}
  a "rm /tmp/t.txt"
  a "sv restart test_service || \"Unable to restart service\""
end

transition :empty => :test2 do
  a 'apt-get update'
  a 'touch /tmp/t2.txt'
  a 'echo :\) > /tmp/t2.txt'
  a 'touch /tmp/t3.txt'
  a 'echo blo\! > /tmp/t3.txt'
  a 'apt-get -q -y install runit=1.4'
  a 'mkdir -p /etc/sv/test_service'
  a 'mkdir -p /etc/sv/test_service/log'
  a 'touch /etc/sv/test_service/run'  
  a 'chmod +x /etc/sv/test_service/run'
  a %q{echo \#\!/bin/sh'
'exec\ 2\>\&1'
''
'sleep\ 300 > /etc/sv/test_service/run}
  a 'touch /etc/sv/test_service/log/run'
  a 'chmod +x /etc/sv/test_service/log/run'
  a %q{echo \#\!/bin/sh'
''
'\#\ store\ logs\ in\ /storage/log\ if\ possible\ \(zombie\ convention\)'
'LOG_FOLDER\=/var/log/test_service'
'if\ \[\ -d\ /storage\ \]\;\ then'
'\ \ \ \ LOG_FOLDER\=/storage/log/test_service'
'fi'
''
'mkdir\ -p\ \$LOG_FOLDER'
'exec\ svlogd\ -tt\ \$LOG_FOLDER > /etc/sv/test_service/log/run}
  a 'ln -f -s /etc/sv/test_service/ /etc/service/test_service'
  a 'mkdir -p /tmp/lorenz'
  a 'mkdir -p /tmp/lorenz/executes'
  a 'touch /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
  a 'echo \(1..20\).each\ \{\|i\|\ sleep\ 1\ unless\ ::FileTest.pipe\?\(\"/etc/sv/test_service/supervise/ok\"\)\ \} > /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
  a 'ruby /tmp/lorenz/executes/4e55f1e3f2b1cafda28a382b7d6cb3f8839d1b5d.ruby'
  a 'sv start test_service'
end

transition :empty => :version_test1 do
  a "apt-get update"
  a "apt-get -q -y install git=1.5"	
end

transition :empty => :version_test2 do
  a "apt-get update"
  a "apt-get -q -y install git=1.6"	
end

transition :empty => :version_test3 do
  a "apt-get update"
  a "apt-get -q -y install git=1.7"	
end

transition :empty => :version_test4 do
  a "apt-get update"
  a "apt-get -q -y install git=1.8"	
end

transition :empty => :version_test5 do
  a "apt-get update"
  a "apt-get -q -y install git=2.0"	
end

transition :empty => :ohai do
  a 'apt-get update'
  a 'apt-get -q -y install ruby=1.8.7'
  a 'apt-get -q -y install rubygems=1.3.7'
  a 'apt-get -q -y install irb=0.9.5'
  a "gem install ohai -v 2"	
  a "ohai"
end