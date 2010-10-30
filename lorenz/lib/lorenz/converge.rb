module Lorenz
  class Converge
    attr_accessor :host, :done_actions, :actions_to_do, :history, :status
    def initialize(host, actions = [])
      @host, @actions_to_do = host, actions
      # @history = []
      @done_actions = []
      @status = :undefined
    end
    
    def perform(history, with_rollback = true)
      self.history = history
      self.status = :in_progress
      actions_to_do.each do |action|
        @cmd = action.command
        action.run
        done_actions << action
        history << ['success', @cmd]
      end
      self.status = :success
      host.converged
    rescue => e
      # raise e 
      # TODO разобраться с логами
      puts "\n\n#{e.class} (#{e.message}):\n    " +
            e.backtrace.join("\n    ") +
            "\n\n"
      self.status = :failed
      history << ['failed', @cmd, e.inspect]
      rollback if with_rollback
    end
    
    def success?
      status == :success
    end
    
    def rollback
      done_actions.reverse.each do |action|        
        @cmd = action.rollback_cmd
        action.rollback
        history << ['rollback', @cmd] if @cmd
        # puts done_actions.reverse.map(&:to_s) * "\n"
      end
    rescue => e
      history << ['failed', @cmd, e.inspect]
    end
  end
end