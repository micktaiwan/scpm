class StreamsController < ApplicationController

  def index
  end
  
  def show
    id = params['id']
    @stream = Stream.find(id)
  end
  
  def show_stream_projects
    id = params['id']
    @stream = Stream.find(id)
    @projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.first(@stream.workstream).name])
  end
  
  def show_stream_informations
    id = params['id']
    @stream = Stream.find(id)
    # Get all Requests
  end
  
  def show_stream_review
    id = params['id']
    review_type = params['type']
    @stream = Stream.find(id)
  end
  
end
