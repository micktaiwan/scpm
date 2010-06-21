class WelcomeController < ApplicationController

  def index
    #@report = Report.new('/home/mick/DL/mfaivremacon.csv')
    @report = Report.new('D:\DL\mfaivremacon.csv')
    @report.parse
  end

end
