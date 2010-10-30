module Lorenz
  module Mixin
    module DSLLoad
      def load_from_block(&blk)
        instance_eval(&blk)
        self
      end
      
      def load_from_file(file_path)
        instance_eval(Pathname(file_path).read, file_path)        
        self
      end
    end
  end
end