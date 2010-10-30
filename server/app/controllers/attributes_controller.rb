class AttributesController < InheritedResources::Base
  belongs_to :host

  def create
    parent.update_attribute :lorenz_attributes, ActiveSupport::JSON.decode(params[:attributes])
    flash[:success] = "Attributes saved"
    redirect_to host_path(@host)
  end
end
