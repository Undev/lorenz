module HostsHelper
  def ordered_hosts(hosts)
    order_map = { 
      :in_progress => 1,
      :success => 2,
      :failed => 3,
      :undefined => 4
      }
    hosts.sort_by { |v| order_map[v.state.to_sym] }
  end  
end
