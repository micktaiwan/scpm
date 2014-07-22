class PeopleController < ApplicationController

  before_filter :require_login
  if APP_CONFIG['project_name']=='EISQ'
    layout 'tools'
  else
    layout 'mp_tools'
  end

  def index
    @people = Person.find(:all, :order=>"company_id, has_left, is_transverse, name")
    @allCompanies = Person.all(:select => "DISTINCT(company_id)")
  end

  def new
    @person = Person.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
    @roles = Role.find(:all, :conditions=>"name != 'Super'")
    cost_profiles = CostProfile.all(:order=>'company_id, name')
    @profiles = []
    if cost_profiles
      @profiles = cost_profiles.map {|u| [u.company.name + ' - ' + u.name,u.id]}
    end
  end

  def check_settings
    Person.find(:all, :conditions=>["settings IS NULL"]).each do |p|
      p.save_default_settings
    end
    render(:nothing=>true)
  end

  def create
    @person = Person.new(params[:person])
    @person.save_default_settings

    if not @person.save
      render :action => 'new'
      return
    else
      @roles = Role.find(:all, :conditions=>"name != 'Super'")
      @roles.each { |r|
        if params[:role][r.name.to_sym] == '1'
          @person.add_role(r.name)
        else
          @person.remove_role(r.name)
        end
        }
    end
    redirect_to('/people')
  end

  def show
    @people = Person.find(:all, :order=>"name")
    id            = params[:id]
    @person       = Person.find(id)
    @person.update_timeline
    @requests     = @person.requests
    @next         = @requests.select { |r| if r.start_date ==""; return true; else; Date.parse(r.start_date) >= Date.today() and Date.parse(r.start_date) <= Date.today()+30; end}.sort_by { |r| r.start_date}
  end

  def edit
    @person = Person.find(params[:id])
    @tbp_collabs = TbpCollab.all
    @companies = Company.all(:order=>'name')
    cost_profiles = CostProfile.all(:order=>'company_id, name')
    @profiles = []
    if cost_profiles
      @profiles = cost_profiles.map {|u| [u.company.name + ' - ' + u.name,u.id]}
    end
    @roles = Role.find(:all, :conditions=>"name != 'Super'")
  end

  def update
    id = params[:id]
    @person = Person.find(id)

    if @person.update_attributes(params[:person]) # do a save
      @roles = Role.find(:all, :conditions=>"name != 'Super'")
      @roles.each { |r|
        if params[:role][r.name.to_sym] == '1'
          @person.add_role(r.name)
        else
          @person.remove_role(r.name)
        end
        }
      login = params[:person][:login]
      p = Person.find(:all, :conditions=>["login=?", login]) 
      if p.size > 1
        @person.login = ""
        @person.save
        flash[:error] = "Duplicate login with #{p.map{|i| '<a href=\'/people/edit/'+i.id.to_s+'\'>'+i.name+'</a>'}.join(', ')}"
        redirect_to "/people/edit/#{id}"
        return
      else
        redirect_to "/people/"
      end
    else
      render :action => 'edit'
    end
  end

end
