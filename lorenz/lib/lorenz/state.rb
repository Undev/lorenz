module Lorenz
  class State
    attr_accessor :node_list, :after_init_blocks
    def initialize
      @node_list, @after_init_blocks = NodeList.new, {}
    end
    
    def load_from_file(file_path)
      
    end
    
    def load_from_block(&blk)
      
    end

  end  
end