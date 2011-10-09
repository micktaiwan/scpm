class SdpLogsController < ApplicationController

  def create
    date = params[:date]
    person_id = params[:person_id]
    initial   = params[:initial]
    sdp_remaining = params[:sdp_remaining]
    wl_remaining  = params[:wl_remaining]
    delay   = params[:delay]
    balance = params[:balance]
    percent = params[:percent]
    log = SdpLog.find(:first, :conditions=>["person_id=? and date=?", person_id, date])
    if log
      log.update_attributes(:person_id=>person_id,
        :date=>date,
        :initial => initial,
        :sdp_remaining => sdp_remaining,
        :wl_remaining  => wl_remaining,
        :delay   => delay,
        :balance => balance,
        :percent => percent)
        log.save
    else
      log = SdpLog.create(:person_id=>person_id,
        :date=>date,
        :initial => initial,
        :sdp_remaining => sdp_remaining,
        :wl_remaining  => wl_remaining,
        :delay   => delay,
        :balance => balance,
        :percent => percent)
    end
    logs = SdpLog.find(:all, :conditions=>["person_id=?", person_id], :order=>"`date`", :limit=>3)
    render(:partial=>"log", :collection=>logs, :layout=>false)
  end

end

