module Converger
  class Controller
    DEFAULT_OPTIONS = {
      :workers => 5,
      :schedule_timeout => 30,
      :face_port => AppConfig[:converger_port]
    }

    attr_accessor :options
    attr_accessor :signals_queue, :tasks_queue
    attr_accessor :current_tasks, :current_runs
    attr_accessor :workers
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge options
      @signals_queue, @tasks_queue = Queue.new, Queue.new
      @current_tasks, @current_runs = {}, {}
    end
  
    def start
      Rails.logger.info "Starting converge perfomer"
      reload
      start_workers
      start_em
      start_loop      
    end
  
    def start_em
      Thread.new do
        EM.run do
          start_face
          start_webscokets
        end
      end
    end
  
    def task_info(host)
      if current_tasks[host]
        current_tasks[host]
      else
        subscribers = []
        current_tasks[host] = { :history => RunHistory.new(subscribers), :subscribers => subscribers, :in_progress => false }
      end
    end
  
    def start_face
    
      # fork do
        Face.start self
      # end.join
    end
  
    def start_webscokets
      WebSockets.start self
    end
  
    def start_workers
      self.workers = ThreadGroup.new
      options[:workers].times do |i|
        Rails.logger.info "Worker #{i} starting"
        thread = Thread.new do
          Worker.new(self).start_loop          
        end
        workers.add thread
      end
    end
  

  
    def start_loop
      while (signal = signals_queue.pop)
        Rails.logger.info "Signal #{signal.first}"
        case signal.first
        when :reload
          reload
        # when :converge_right_now
        #   _, host_name = signal
        #   converge_right_now host_name
        end
      end
    end
  
    def reload
      Rails.logger.info "Reloading recipes and hosts"
      tasks_queue.clear
      while current_tasks.select { |k, v| v[:in_progress] }.size > 0
        sleep 1
      end
      Recipe.load_original
      hosts = Host.all
      hosts.each do |host|
        Rails.logger.debug "#{host.name} added to task queue"
        host.update_state :undefined
        tasks_queue << Task.new(:converge, :host => host) 
      end
    end
  
    def converge_right_now(host_name)
      host = Host.all.detect { |v| v.name == host_name }
      return unless host
      host.update_state :undefined
      thread = Thread.new do
        Worker.new(self).new_task Task.new(:converge, :host => host)
      end
      workers.add thread
    end    
  end
end