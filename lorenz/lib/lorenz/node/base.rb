module Lorenz
  module Node
    class Base
      # include ActiveSupport::Callbacks
      # define_callbacks :init
      class_attribute :params_list, :childs_block, :after_init_block, :after_all_init_block
      attr_accessor :host
      attr_accessor :parent, :childs
      mattr_accessor :node_name_map, :versions_nodes
      self.params_list = []
      @@node_name_map, @@versions_nodes = {}, []
      class << self
        # def params_list
        #   @params_list ||= self
        # end
        
        def params(*new_params)
          self.params_list += new_params
          attr_accessor(*new_params)
        end
        
        def version_param(name)
          versions_nodes << [self.name, name]
          params name
          class_eval <<-EOV
            def #{name}
              get_version(:#{name})
            end
          EOV
        end
        
        def node_params_map
          @node_params ||= {}
        end
        
        def node_params(*new_params)          
          new_params.each do |param|
            class_eval <<-EOV
              def #{param}
                node_params_map[id] && node_params_map[id]['#{param}']
              end
              def #{param}=(val)
                node_params_map[id] ||= {}
                node_params_map[id]['#{param}'] = val
              end
            EOV
          end
        end
        
        def childs(&block)
          self.childs_block = block
        end
        
        def after_init(&block)
          self.after_init_block = block
        end
        
        def after_all_init(&block)
          self.after_all_init_block = block
        end
        
        def node_name
          self.name.demodulize.underscore
        end
        
        def inherited(subclass)
          DSL.define_node_method subclass
          node_name_map[subclass.node_name] = subclass.name
        end
      end

      def initialize(params, host)
        # run_callbacks :init do
          @host = host
          params.each do |k, v|
            self.send("#{k}=", v)
          end
          @childs = []
        # end
      end
      
      def get_version(param)
        val = instance_variable_get "@#{param}"
        if val && val.is_a?(Symbol)
          variant = val
        elsif val
          return val
        else
          variant = nil
        end
        Lorenz.versions.find("#{self.class.name}-#{name}", host, variant) || raise("Undefined version for #{name} (#{self.class.name}) host #{host.options[:name]}")
      end
      
      def childs_changed(nodes = [])
        []
      end
      
      # TODO здесь у одной и той же ноды может быть вызвано несколько раз childs_changed. Наверно на каком то уровне нужно агрегировать такие вызовы
      def perform_childs_changed(nodes = [])
        childs_changed + (parent ? parent.perform_childs_changed([self]) : [])
      end
      
      def new?
        @status == :created
      end

      def perform_create
        @status = :created
        create
      end
      
      def create
        []
      end
      
      def perform_destroy
        @status = :destroyed
        destroy
      end
      
      def destroy
        []
      end
      
      def perform_change(change_params)
        @status = :changed
        change change_params
      end
      
      def change(changed_params)
        changed_params.map do |name, (from, to)|
          set_param name.to_sym, from, to
        end.compact.flatten
      end
      
      def set_param(nam, from, to)
        []
      end
      
      def child(node_name, id)
        childs.detect { |v| v.key == "#{self.class.node_name_map[node_name.to_s]}-#{id}" }
      end
      


      def params
        params_list.inject({}) do |res, param|
          res[param] = send param
          res
        end
      end
      
      def node_params_map
        self.class.node_params_map
      end

      def params_list
        self.class.params_list
      end
      
      def id
        rescue 'redefine id'
      end

      def key
        "#{self.class.name}-#{id}"
      end

      def self.cmd(cmd, rollback_cmd = nil, node = nil, &collback)
        Action.new cmd, rollback_cmd, node, &collback
      end
      
      def self.delayed_cmd(cmd, rollback_cmd = nil, node = nil, &collback)
        DelayedAction.new cmd, rollback_cmd, node, &collback
      end
      
      def cmd(cmd, rollback_cmd = nil, &collback)
        self.class.cmd cmd, rollback_cmd, self, &collback
      end
      
      def delayed_cmd(cmd, rollback_cmd = nil, &collback)
        self.class.delayed_cmd cmd, rollback_cmd, self, &collback
      end
      # def cmd(cmd)
      #   `#{cmd}`
      #   unless $?.exitstatus == 0
      #     raise "#{cmd} exit with status code #{$?.exitstatus}"
      #   end
      # end
      def all_params
        params.merge(node_params_map[id] || {})
      end
      
      def reverse_actions(actions)
        actions.reverse.map do |action|
          cmd action.rollback_cmd, action.command
        end
      end

      def serialize
        { 'type' => self.class.name,
          'key' => key,
          'params' => all_params
        }
      end
      
      def inspect
        (["#{self.class.name}"] +
        all_params.inject([]) do |res, (k, v)| 
          res << "#{k.to_s.titleize}: #{v}" if v
          res
        end) * "\n"
      end
    end
  end
end