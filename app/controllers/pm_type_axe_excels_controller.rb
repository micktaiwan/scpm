class PmTypeAxeExcelsController < ApplicationController
  layout "tools_spider"
  def index
    @lifecycles = Lifecycle.all.map {|u| [u.name,u.id]}    

    @lifecycle_id = params[:lifecycle_id]
    if @lifecycle_id == nil
      @lifecycle_id = 1
    end

    @excel_axes = PmTypeAxeExcel.find(:all,:conditions=>["lifecycle_id=?", @lifecycle_id])
  end

  def refresh_index
    @lifecycle_id = params[:lifecycle_id]
    if @lifecycle_id == nil
      @lifecycle_id = 1
    end
    @excel_axes = PmTypeAxeExcel.find(:all,:conditions=>["lifecycle_id=?", @lifecycle_id])
    render :layout => false  
  end

  def new
    @axes = PmTypeAxe.find(:all).map {|u| [u.title,u.id]} 
    @lifecycle_id = params[:lifecycle_id]
    @pmtypeaxeexcel = PmTypeAxeExcel.new(:lifecycle_id=>@lifecycle_id)
  end

  def create
    @pmtypeaxeexcel = PmTypeAxeExcel.new(params[:pmtypeaxeexcel])
    @pmtypeaxeexcel.save
    redirect_to("/pm_type_axe_excels")
  end

  def edit
    id = params[:id]
    @lifecycle_id = params[:lifecycle_id]
    @axes = PmTypeAxe.find(:all).map {|u| [u.title,u.id]} 
    @pmtypeaxeexcel = PmTypeAxeExcel.find(id)
  end

  def update
    pmtypeaxeexcel = PmTypeAxeExcel.find(params[:id])
    pmtypeaxeexcel.update_attributes(params[:pmtypeaxeexcel])
    redirect_to("/pm_type_axe_excels")
  end

  def destroy
    PmTypeAxeExcel.find(params[:id].to_i).destroy
    redirect_to("/pm_type_axe_excels")
  end

  def show
  end

end
