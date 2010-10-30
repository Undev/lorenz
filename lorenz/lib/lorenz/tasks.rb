module Lorenz
  class Tasks < ::Rake::TaskLib
    attr_accessor :client_block
    
    # @param [Proc] client_block блок, возвращающий инстанс {TeleguideClient::Base}
    def initialize(&client_block)
      self.client_block = client_block
      define
    end
    
    def client
      client_block.call
    end
    
    def define
    
    end
  end
  
end