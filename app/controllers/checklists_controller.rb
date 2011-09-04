class ChecklistsController < ApplicationController

  def show
    milestone_id = params[:id]
    render(:text=>"hello "+milestone_id)
  end

end

