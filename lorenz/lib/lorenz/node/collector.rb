module Lorenz
  module Node
    class Collector < Base
      params :command, :attribute_name, :clb, :filter
      
      def create
        blk = unless clb
          proc do |res|
            host.attributes[attribute_name] = filter ? filter.call(res) : res
          end
        else
          clb
        end
        [cmd command, nil, &blk]
      end
      
      # Точно, да?
      def destroy
        host.attributes.delete attribute_name
        []
      end
      
      def id
        "#{command}-#{attribute_name}"
      end
    end
  end
end