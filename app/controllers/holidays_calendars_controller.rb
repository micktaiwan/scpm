class HolidaysCalendarsController < ApplicationController

  before_filter :require_login
  layout 'pdc'

  def index
    @holidays_calendar = HolidaysCalendar.find(:all, :order=>"name")
  end

  def new
    @holidays_calendar = HolidaysCalendar.new
  end

  def create
    @holidays_calendar = HolidaysCalendar.new(params[:holidays_calendar])
    if not @holidays_calendar.save
      render :action => 'new'
      return
    end
    redirect_to('/holidays_calendars')
  end

  def edit
    @holidays_calendar = HolidaysCalendar.find(params[:id])
  end

  def update
    id = params[:id]
    @holidays_calendar = HolidaysCalendar.find(id)
    if @holidays_calendar.update_attributes(params[:holidays_calendar]) # do a save
      redirect_to "/holidays_calendars"
    else
      render :action => 'edit'
    end
  end

  def destroy
    HolidaysCalendar.find(params[:id]).destroy
    redirect_to('/holidays_calendars')
  end
end
