class PmTypeAxesController < ApplicationController
  layout 'tools'
  
  def index
    @pm_type_axes = PmTypeAxe.all()
  end

  def new
    @pm_type_axe = PmTypeAxe.new()
    @pm_types = PmType.all.map {|u| [u.title,u.id]}
  end
  
  def create
     @pm_type_axe = PmTypeAxe.new(params[:pm_type_axe])
     if not @pm_type_axe.save
       render :action => 'new'
       return
     end
     
     @pm_type_axes = PmTypeAxe.all()
     redirect_to :action => 'index'
  end

  def edit
    @pm_type_axe = PmTypeAxe.find(params[:id])
    @pm_types = PmType.all.map {|u| [u.title,u.id]}
  end
  
  def update
    @pm_type_axe = PmTypeAxe.find(params[:id])
    if @pm_type_axe.update_attributes(params[:pm_type_axe])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
     PmTypeAxe.find(params[:id].to_i).destroy
     redirect_to :action => "index"
  end
end
