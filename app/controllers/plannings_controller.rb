class PlanningsController < ApplicationController

  layout 'pdc'

  def index
    @plannings = Planning.all
    id = params[:id]
    if id
      @planning = Planning.find(id)
    end
  end

  def new
    Planning.create(:name=>'test')
    render(:text=>'ok')
  end

end
