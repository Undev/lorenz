file "/tmp/t.txt", :content => 'Hello world'  
file :path => "/tmp/t2.txt", :content => ':)'
file :path => "/tmp/t3.txt", :content => 'blo!'

# include_recipe :test2
# include_recipe "runit::definition"
runit_service :name => "test_service", :run_command => "sleep 700"

# git "/tmp/git", :url => "git://git.undev.cc/teleguide/teleguide-face.git", :revision => 'production'

# 100.times do |i|
#   deploy "/tmp/git#{i}", :url => "git://git.undev.cc/teleguide/teleguide-face.git", :revision => 'production'
# end