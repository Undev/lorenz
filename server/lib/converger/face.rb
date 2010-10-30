module Converger
  class Face < EM::Connection
    include EM::HttpServer
    def self.start(controller)      
        EM.start_server '0.0.0.0', controller.options[:face_port], self do |c|
          c.controller = controller
        end
        
      # Rainbows.run self.new(controller)
      
      # Rails.logger.info "Converge perfromer face starting on port #{controller.options[:face_port]}"
      #       @@server = ::Thin::Server.start('0.0.0.0', controller.options[:face_port], self, :signals => false) do
      #         use ::Rack::ShowExceptions
      #         run Face.new controller
      #       end
    end
    
    attr_accessor :controller
    # def initialize(controller)
    #   @controller = controller
    #   super
    # end
    
    PUBLIC_ROOT = File.join(APP_PATH, 'public')
    
    ROUTES = {
      /\/reload/ => :reload
    }
  
    def post_init
     super     
     no_environment_strings
    end

    def process_http_request
      # puts "Handle http request"
      puts @http_request_uri      
      @response = EM::DelegatedHttpResponse.new(self)
      @http_request_uri = '/index.html' if @http_request_uri == '/'
      if @http_request_uri == '/index.html'
        hello
      elsif File.exist?(File.join(PUBLIC_ROOT, @http_request_uri))
        stream_static_file File.join(PUBLIC_ROOT, @http_request_uri)
      elsif (route = ROUTES.detect { |k, v| @http_request_uri.match(k) })
        self.send(route[1], *($~.to_a[1, $~.size]))  
      else
        @response.status = 404
        @response.send_response
      end
    end
    
    def json_response(data, status = 200)
      @response.status = status
      @response.content = data.to_json
      @response.headers['Connection'] = 'close'
      @response.headers['Content-Type'] = 'text/json'
      @response.send_response
    end
    
    def stream_static_file(file_path)
      @response.chunk true # little hack
      @response.send_headers
      streamer = EventMachine::FileStreamer.new(self, file_path, :http_chunks => true)
      streamer.callback do
        close_connection_after_writing
      end
    end
    
    def hello
      json_response controller.workers.list.map { |v| v.inspect }
    end
    
    def reload
      Rails.logger.debug "HTTP: reload action"    
      controller.signals_queue << [:reload]
      json_response :ok
    end
  end
end