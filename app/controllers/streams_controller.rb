class StreamsController < ApplicationController

  def index
  end
  
  def show
    id = params['id']
    @stream = Stream.find(id)
    
  end
  
end
