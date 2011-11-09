class ReqCategoriesController < ApplicationController

  layout 'tools'

  def index
    @cats = ReqCategory.all
  end

  def new
    @cat = ReqCategory.new
  end

  def create
    @cat = ReqCategory.new(params[:cat])
    if not @cat.save
      render :action => 'new'
      return
    end
    redirect_to('/req_categories')
  end

end

