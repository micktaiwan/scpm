class HolidaysController < ApplicationController

  before_filter :require_login
  layout 'pdc'

  def index
    @holidays = WlHoliday.find(:all, :order=>("wl_holidays_calendar_id, week"))
  end

  def new
    @holiday = WlHoliday.new
    Company.create(:name=>"SQLI") if Company.find(:first) == nil
    @companies = Company.all
    @roles = Role.find(:all, :conditions=>"name != 'Super'")
  end

  def create
    @holiday = WlHoliday.new(params[:holiday])
    if not @holiday.save
      render :action => 'new'
      return
    end
    redirect_to('/holidays')
  end

  def edit
    @holiday = WlHoliday.find(params[:id])
  end

  def update
    id = params[:id]
    @holiday = WlHoliday.find(id)
    if @holiday.update_attributes(params[:holiday]) # do a save
      redirect_to "/holidays"
    else
      render :action => 'edit'
    end
  end

  def destroy
    WlHoliday.find(params[:id]).destroy
    redirect_to('/holidays')
  end
end
