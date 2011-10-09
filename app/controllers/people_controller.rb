class PeopleController < ApplicationController

  before_filter :require_login
  layout 'tools'

  def index
    @people = Person.find(:all, :order=>"company_id, has_left, is_transverse, name")
  end

  def new
    @person = Person.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
    @roles = Role.find(:all, :conditions=>"name != 'Super'")
  end

  def create
    @person = Person.new(params[:person])
    if not @person.save
      render :action => 'new'
      return
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
    @companies = Company.all
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
      redirect_to "/people/show/#{@person.id}"
    else
      render :action => 'edit'
    end
  end

end
