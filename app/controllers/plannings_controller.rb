class PlanningsController < ApplicationController

  layout 'pdc'

  def index
    @plannings = Planning.all
    id         = params[:id]
    @planning  = Planning.find(id) if id
  end

  def new
    # TODO
    Planning.create(:name=>'eLogbook')
    redirect_to :action=>'index'
  end

end
