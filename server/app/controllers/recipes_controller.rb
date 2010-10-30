require 'open-uri'
class RecipesController < InheritedResources::Base
  belongs_to :host, :optional => true
  

  def create
    association_chain
    @host.recipes << Recipe.find(params[:recipe_id])
    @host.save
    redirect_to parent
  end
  
  def destroy
    # Вот тут ну совсем какой то пиздец пошел
    association_chain
    @host.recipes.delete Recipe.find(params[:id])
    @host.recipes.replace @host.recipes.target
    @host.save
    redirect_to parent
  end
  
  def collection
    @recipes ||= end_of_association_chain.all
  end
  
  def reload
    open("http://localhost:#{AppConfig[:converger_port]}/reload")
    Recipe.load_original
    flash[:success] = 'Recipes reloaded'
  rescue => e
    flash[:error] = 'Error with reloading recipes'
    Rails.logger.warn e.inspect
  ensure
    redirect_to root_path
  end
end
