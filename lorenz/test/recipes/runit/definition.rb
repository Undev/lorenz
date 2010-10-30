# node :runit_service, :name do
#   include_recipe "runit"
#   
#   file :path => "/tmp/#{dependent.params[:name]}"
# end