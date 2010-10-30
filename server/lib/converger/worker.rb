module Converger
  class Worker
    
    attr_accessor :controller
    def initialize(controller)
      @controller = controller
    end
    
    def start_loop
      while task = controller.tasks_queue.pop
        new_task task
      end
    end
    
    def new_task task
      Rails.logger.info "New task for worker: #{task.type}"
      # controller.current_runs[task.params[:host]] = []
      controller.task_info(task.params[:host].name)[:in_progress] = true
      case task.type
      when :converge
        converge task
      else
        Rails.logger.warn "Undefined task #{task}"
      end
      # controller.current_runs.delete task.params[:host]
      controller.current_tasks.delete task.params[:host].name
    end
    
    def converge(task)
      host = task.params[:host]
      Rails.logger.debug "Converging #{host.name}"      
      host.update_state :in_progress
      host.lorenz.apply_recipes
      if (diff = host.lorenz.diff).size > 0        
        converge = Lorenz::Converge.new host.lorenz, diff
        
        history = controller.task_info(task.params[:host].name)[:history]
        converge.perform(history)
        if converge.success?
          Rails.logger.debug "Converging #{host.name} success"      
          host.converge_completed :success, history
        else
          Rails.logger.debug "Converging #{host.name} failed"      
          host.converge_completed :failed, history
        end
      else
        host.update_state :success
      end      
    end
  end
end