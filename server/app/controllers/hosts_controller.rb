class HostsController < InheritedResources::Base
  respond_to :html, :json
  
  def show
    show! do |format|
      format.json do
        render :json => resource.to_json
      end
    end
  end

  
  def destroy
    resource.destroy
    flash[:success] = "Host #{@host.name} deleted"
    redirect_to root_path
  end
  
  def set_recipes
    resource.recipes = params[:ids] ? params[:ids].sort_by { |k, v| k }.map { |k, id| Recipe.find(id) } : [] # По идее тут не ordered хеш 
    resource.save
    render :text => ''
  end
  
  def current_state
    @state = resource.current_states
  end
  
  def new_state
    resource.lorenz.apply_recipes
    @state = resource.lorenz.node_list
  end
  
  def diff
    resource.lorenz.apply_recipes
    @diff = resource.lorenz.diff
  end
  
  def attributes
    
  end
  
  def reset
    resource.reset!
    redirect_to host_path resource
  end
  
  def collection
    @hosts ||= end_of_association_chain.all
  end
end
