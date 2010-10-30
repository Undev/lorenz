# service :name => 'test_run' do
#   start_command 'start'
#   restart_command 'restart'
#   childs do
#     file :path => "/tmp/t4.txt", :content => 'included! and changed! and again!', :mode => '0777'
#   end
# end

# package :name => 'ruby1.8', :version => '1.8.7.72-3lenny1'
# package :name => 'rubygems', :version => '1.3.7-1bbox1-lenny1'
# package :name => "ssh", :version => '1:5.1p1-5'
# 
# gem :name => 'rails', :version => '3.0.0'


# file "/tmp/t.txt", :content => 'Hello world'  
# file :path => "/tmp/t2.txt", :content => ':)'
# file :path => "/tmp/t3.txt", :content => 'blo!'
# 
# file :path => "/tmp/t5.txt", :content => 'blo!'
# file :path => "/tmp/t6.txt", :content => 'blo!'
# file :path => "/tmpasd/t7.txt", :content => 'blo!'

execute :command => template('test.rb'), :lang => :ruby