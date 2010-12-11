class TopicsController < ApplicationController

  def index
    @topics         = Topic.find(:all, :conditions=>"done = 0", :order=>"id desc")
    @topics_closed  = Topic.find(:all, :conditions=>"done = 1", :order=>"id desc")
  end

  def new
    @topic = Topic.new(:person_id=>current_user.id)
    @people         = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name")
  end

  def create
    @topic = Topic.new(params[:topic])
    if not @topic.save
      render :action => 'new', :person_id=>current_user.id
      return
    end
    redirect_to("/topics")
  end

  def edit
    id = params[:id]
    @topic = Topic.find(id)
    @people         = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name")
  end

  def update
    a = Topic.find(params[:id])
    done = a.done
    a.update_attributes(params[:topic])
    if(params[:topic][:done]=="1" and done != a.done)
      a.done_date = Time.now
      a.save
    end
    redirect_to "/topics"
  end

  def destroy
    Topic.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

end

