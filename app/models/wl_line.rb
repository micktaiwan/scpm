class WlLine < ActiveRecord::Base

  has_many :wl_loads, :dependent => :destroy
  belongs_to :person
  belongs_to :request
  belongs_to :sdp_task, :class_name=>"SDPTask"

  include ApplicationHelper

  def sdp_task
    SDPTask.find_by_sdp_id(self.sdp_task_id)
  end

  def load_by_week(week)
    WlLoad.find(:first, :conditions=>["wl_line_id=? and week=?", self.id, week])
  end

  def get_load_by_week(week)
    l = load_by_week(week)
    l ? l.wlload : 0.0
  end

  def planned_sum
    #wl_loads.inject(0) { |sum, l| sum+l.wlload}
    return 0 if wl_loads.size == 0
    today_week            = wlweek(Date.today)
    sum = wl_loads.map{|load| (load.week < today_week ? 0.0 : load.wlload)}.inject(:+)
    raise "ooops, sum is nil" if not sum
    sum
  end


  def display_name
    #"<a href='#' title='#{name}'>#{name}</a>"
    name
  end

  def request
    Request.find(:first, :conditions=>["request_id=?",filled_number(self.request_id,7)])
  end

  # get milestones for request by week
  def milestones(w)
    return [] if !request or !request.project
    str = w.to_s
    year = str[0..3].to_i
    week = str[4..5].to_i
    week_start  = Date.commercial(year, week, 1)
    week_end    = Date.commercial(year, week, 7)
    rv = []
    r = request
    if r
      r.project.milestones.each { |m|
        date = m.date
        rv << m if date and date >= week_start and date <= week_end
        }
    end
    rv
  end

end

