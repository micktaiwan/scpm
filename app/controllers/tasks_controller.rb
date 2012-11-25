class TasksController < ApplicationController

  layout 'pdc'

  def new
    id = params[:id]
    raise "no planning id" if !id
    Task.create(:planning_id=>id, :name=>'New task', :start_date=>Date.today(), :duration_in_day=>1)
    redirect_to :controller=>'plannings', :action=>'index', :id=>id
  end

end
