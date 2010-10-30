module Converger
  class Task
    attr_accessor :type, :params
    def initialize(type, params = {})
      @type, @params = type, params
    end
    
  end
end