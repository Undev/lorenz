require 'evma_httpserver'

module Converger
  
  extend ActiveSupport::Autoload
  
  autoload :Controller
  autoload :RunHistory
  autoload :WebSockets
  autoload :Worker
  autoload :Task
  autoload :Face
  
  def self.start
    Thread.new do
      Controller.new.start
    end
    
    Thread.new do
      loop { sleep 5 }
    end.join    
  end
end