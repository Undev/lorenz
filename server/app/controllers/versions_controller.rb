class VersionsController < InheritedResources::Base
  respond_to :html, :json
  
  def index
    index! do |format|
      format.json do
        render :json => collection.to_json
      end
    end
  end
  
  def create
    VersionsSet.default.add(params)    
    redirect_to versions_path
  end
  
  def remove
    VersionsSet.default.remove(params)
    redirect_to versions_path
  end
  
  
  def collection
    @versions ||= VersionsSet.default
  end
end