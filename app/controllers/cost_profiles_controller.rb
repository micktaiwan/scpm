class CostProfilesController < ApplicationController

  before_filter :require_login
  if APP_CONFIG['project_name']=='EISQ'
    layout 'tools'
  else
    layout 'mp_tools'
  end

  def index
    @cp = CostProfile.find(:all, :order=>"company_id, name")
    @companies = Company.all(:order=>"name")
  end

  def new
    @profile = CostProfile.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
  end

  def create
  	session['company_id'] = params[:profile][:company_id]
    @profile = CostProfile.new(params[:profile])
    @profile.save
    redirect_to('/cost_profiles')
  end

  def destroy
    CostProfile.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

end
