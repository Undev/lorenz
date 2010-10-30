class Host
  include Ripple::Document
  many :recipes
  
  key_on :name
  
  property :name, String
  property :ssh_user, String, :default => 'root'
  property :ip, String
  property :state, String, :default => 'undefined'
  
  property :current_states, Array, :default => []
  
  property :last_run, Array, :default => []
  property :lorenz_attributes, Hash, :default => {}
  
  # state_machine :state do    
  #   event :converging_started do
  #     transition :enqeued => :in_progress
  #   end
  #   
  #   event :converge do
  #     transition any => :enqeued
  #   end
  #   
  #   event :success do
  #     transition :enqeued => :success
  #   end
  #   
  #   event :failure do
  #     transition :enqeued => :failed
  #   end
  # 
  # end
  
  # Хак для стейт машины
  # def initialize(attrs={})
  #   @attributes = attributes_from_property_defaults
  #   self.attributes = attrs
  # end
  
  # def current_state
  #   serialized_current_state ? Lorenz::NodeList.deserialize(serialized_current_state, lorenz) : Lorenz::NodeList.new
  # end
  
  # Хак. links в riak ordered, а вот walk (им получаются ассоциации) нет. Использует патч в riak-client
  # TODO Чувак сказал что это нифига не православно и их ordered это сайд эффект. http://github.com/seancribbs/ripple/pull/79
  # Придумать что-нить нормальное
  def ordered_recipes
    index = recipes.index_by { |v| v.key }
    recipes.send(:links).map { |v| index[v.key] }
  end
  
  def converge_completed(state, history)
    update_attributes :state => state, 
                      :last_run => history, 
                      :current_states => lorenz.current_state.serialize, 
                      :lorenz_attributes => lorenz.attributes
  end
  
  def update_state(to)
    update_attribute :state, to
  end
  
  def reset!
    self.current_states = Lorenz::NodeList.new.serialize
    save
  end
  
  def lorenz_recipes
    ordered_recipes.map(&:lorenz)
  end
  
  def lorenz
    @lorenz ||= Lorenz::Host.new :ip => ip, 
                                 :ssh_user => ssh_user, 
                                 :recipes => lorenz_recipes, 
                                 :current_states => current_states,
                                 :name => name,
                                 :attributes => lorenz_attributes
  end
  
  def to_json
    {
      :current_state => current_states,
      :attributes => lorenz_attributes
    }.to_json
  end
  
end