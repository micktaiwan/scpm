class BandeausController < ApplicationController

  def index
    @bandeaus = Bandeau.find(:all, :conditions=>["person_id = ?", current_user.id], :order=>"id desc")
    @other    = Bandeau.find(:all, :conditions=>["person_id != ?", current_user.id], :order=>"id desc")
  end

  def new
  end

  def create
    @bandeau = Bandeau.new(params[:bandeau])
    @bandeau.person_id = current_user.id
    if not @bandeau.save
      render :action => 'new'
      return
    end
    redirect_to('/bandeaus')
  end

  def destroy
    b = Bandeau.find(params[:id].to_i)
    b.destroy
    render(:nothing=>true)
  end

end
