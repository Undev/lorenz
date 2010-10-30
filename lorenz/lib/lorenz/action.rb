module Lorenz
  class Action
    attr_accessor :command, :rollback_cmd, :node, :callback
    attr_accessor :type
    def initialize(command, rollback_cmd, node, &block)
      @command, @rollback_cmd, @node = command, rollback_cmd, node
      @callback = block
    end
    
    def ssh_cmd
      'ssh'
    end
    
    def ssh_flags
      []
    end
    
    def ip
      node.host.options[:ip]
    end
    
    def ssh_user
      node.host.options[:ssh_user]
    end
    
    def rollback
      execute rollback_cmd if rollback_cmd
    end
    
    def run
      execute command
    end
      
    def execute(cmd)
      puts cmd
      cmd     = [ssh_cmd, ssh_flags, "#{ssh_user}@#{ip}", cmd].flatten      
      # cmd = ["sleep 1"]
      result  = []
      pid, inn, out, err = Open4::popen4(*cmd)

      inn.sync   = true
      streams    = [out, err]
      out_stream = {
        out => $stdout,
        err => $stderr,
      }

      # Handle process termination ourselves
      status = nil
      Thread.start do
        status = Process.waitpid2(pid).last
      end

      until streams.empty? do
        # don't busy loop
        selected, = select streams, nil, nil, 0.1

        next if selected.nil? or selected.empty?

        selected.each do |stream|
          if stream.eof? then
            streams.delete stream if status # we've quit, so no more writing
            next
          end

          data = stream.readpartial(1024)
          out_stream[stream].write data

          result << data
        end
      end

      unless status.success? then
        raise "execution failed with status #{status.exitstatus}: #{cmd.join ' '}"
      end
      
      result = result.join
      callback.call result if callback
      
      result
    ensure
      inn.close rescue nil
      out.close rescue nil
      err.close rescue nil
    end
    
    def to_s
      command
    end
    
  end
end