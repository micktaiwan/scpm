class ReqWavesController < ApplicationController

  layout 'tools'

  def index
    @waves = ReqWave.all
  end

  def new
    @wave = ReqWave.new
  end

  def create
    @wave = ReqWave.new(params[:wave])
    if not @wave.save
      render :action => 'new'
      return
    end
    redirect_to('/req_waves')
  end

end

