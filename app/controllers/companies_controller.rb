class CompaniesController < ApplicationController

  def edit
    @company = Company.find(params[:id])
  end

  def update
    id = params[:id]
    @company = Company.find(id)
    if @company.update_attributes(params[:company]) # do a save
      redirect_to "/people"
    else
      render :action => 'edit'
    end
  end

end
