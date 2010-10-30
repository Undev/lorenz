module Lorenz
  class Versions
    attr_accessor :data
    
    def initialize
      @data = {}
    end
    
    def find(package, host, variant = nil)
      host_name = host.options[:name]
      queries = []
      queries << "#{host_name}-#{variant}-#{package}" if variant
      queries << "#{host_name}-#{package}"
      queries << "variant-#{variant}-#{package}" if variant
      queries << "#{package}"
      res = nil
      queries.each do |query|
        break if (res = data[query])
      end
      res
    end    
  end
end