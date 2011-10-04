class RolesController < ApplicationController

  layout 'tools'
  
  def index
    @roles = Role.find(:all, :conditions=>"name is null or name != 'Super'")
  end
  
  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
  end
  
  def update
    id = params[:id]
    if not id
      @role = Role.new(params[:role])
    else
      @role = Role.find(params[:id])
      @role.update_attributes(params[:role])
    end
    if not @role.save
      if id
        render :action => 'edit'
      else
        render :action => 'new'
      end
      return
    end
    redirect_to('/roles')
  end
end
