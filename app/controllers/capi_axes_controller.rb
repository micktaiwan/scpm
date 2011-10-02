class CapiAxesController < ApplicationController

  layout 'tools'

  def index
    @axes = CapiAxis.all
  end

  def new
    @axis = CapiAxis.new
  end

  def update
    id = params[:id]
    if not id
      @axis = CapiAxis.new(params[:axis])
    else
      @axis = CapiAxis.find(params[:id])
      @axis.update_attributes(params[:axis])
    end
    if not @axis.save
      if id
        render :action => 'edit'
      else
        render :action => 'new'
      end
      return
    end
    redirect_to('/capi_axes')
  end

  def edit
    id = params[:id].to_i
    @axis = CapiAxis.find(id)
  end

  def destroy
    id = params[:id]
    CapiAxis.find(id).destroy
    render(:nothing=>true)
  end

end

