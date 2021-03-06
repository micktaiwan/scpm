class TopicsController < ApplicationController

  before_filter :require_login

  def index
    get_topics
    @supervisors    = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name").map{|p| [p.name, p.id]} + [["=== Blank decisions",0],["=== SQLI Actions",-1]]
  end

  def get_topics
    p_id  = params[:filter]
    session[:topic_person_id] = p_id if p_id
    if session[:topic_person_id] == ""
      @topics         = Topic.find(:all, :conditions=>"done = 0", :order=>"id desc")
      @topics_closed  = Topic.find(:all, :conditions=>"done = 1", :order=>"done_date desc")
    elsif session[:topic_person_id] == "0"
      @topics         = Topic.find(:all, :conditions=>["done = 0 and decision=''"], :order=>"id desc")
      @topics_closed  = Topic.find(:all, :conditions=>["done = 1 and decision=''"], :order=>"done_date desc")
    elsif session[:topic_person_id] == "-1"
      @topics         = Topic.find(:all, :conditions=>["done = 0 and sqli_action=1"], :order=>"id desc")
      @topics_closed  = Topic.find(:all, :conditions=>["done = 1 and sqli_action=1"], :order=>"done_date desc")
    else
      @topics         = Topic.find(:all, :conditions=>["done = 0 and person_id=?", session[:topic_person_id]], :order=>"id desc")
      @topics_closed  = Topic.find(:all, :conditions=>["done = 1 and person_id=?", session[:topic_person_id]], :order=>"done_date desc")
    end
  end
  
  def refresh
    get_topics
    render(:partial=>"list")
  end

  def new
    @topic  = Topic.new(:person_id=>current_user.id)
    @people = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name")
  end

  def create
    @topic = Topic.new(params[:topic])
    @topic.done_date = Time.now if params[:topic][:done]=="1"
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

