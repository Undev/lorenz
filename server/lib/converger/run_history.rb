module Converger
  class RunHistory < Array
    
    def initialize(subscribers)
      @subscribers = subscribers
      super()
    end
    
    def <<(val)
      super
      @subscribers.each { |v| v.send_updates(val) }
    end    
  end
end