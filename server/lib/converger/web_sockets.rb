module Converger
  class WebSockets < EventMachine::WebSocket::Connection
    mattr_accessor :server
    def self.start(controller)
      
      EM.start_server '0.0.0.0', 4001, self, :debug => true do |c|
        c.controller = controller
        
        c.onopen {
          # puts "WebSocket connection open"
        }

        c.onclose { 
          #puts "Connection closed" 
          c.unsubscribe
        }
        c.onmessage { |msg|
          puts msg
          case msg
          when /current_run (.+)/
            puts "Subscribe to #{$1}"
            c.subscribe $1
          end
        }
      end   

    end
    
    attr_accessor :controller, :current_message, :updates_host
    
    def subscribe(host)
      @updates_host = host
      # send ['success', 'hi'].to_json
      controller.task_info(updates_host)[:subscribers] << self
      controller.task_info(updates_host)[:history].each do |msg|
        send_updates msg
      end
    end
    
    def unsubscribe
      controller.task_info(updates_host)[:subscribers].delete self
    end
    
    def send_updates(message)
      send message.to_json
    end
  
  end
end