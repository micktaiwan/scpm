class PeopleController < ApplicationController

	def index
    @people = Person.find(:all, :order=>"company_id, name")
	end

  def new
    @person = Person.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
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
    id            = params[:id]
    @person       = Person.find(id)
    @requests     = @person.requests
  end
  
  def edit
    @person = Person.find(params[:id])
    @companies = Company.all
  end

  def update
    id = params[:id]
    @person = Person.find(id)
    if @person.update_attributes(params[:person]) # do a save
      redirect_to "/people/show/#{@person.id}"
    else
      render :action => 'edit'
    end
  end
  
end
