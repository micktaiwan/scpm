class CompaniesController < ApplicationController

  before_filter :require_login
  if APP_CONFIG['project_name']=='EISQ'
    layout 'tools'
  else
    layout 'mp_tools'
  end

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
  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])
    if not @company.save
      render :action => 'new'
      return
    end
    redirect_to('/people')
  end
  def destroy
    
    # persons = Person.find(:all, :conditions=>["company_id=?", params[:id]])
    # if persons
    #   persons.each do |p|
    #     p.company_id = nil ;
    #     p.save
    #   end
    # end
    Company.find(params[:id]).destroy
    redirect_to('/people')
  end
end
