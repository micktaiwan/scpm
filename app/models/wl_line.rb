class WlLine < ActiveRecord::Base
  has_many :wl_loads

  include ApplicationHelper

  def load_by_week(week)
    WlLoad.find(:first, :conditions=>["wl_line_id=? and week=?", self.id, week])
  end

  def get_load_by_week(week)
    l = load_by_week(week)
    l ? l.wlload : 0.0
  end

  def display_name
    #"<a href='#' title='#{name}'>#{name}</a>"
    name
  end

  def request
    Request.find(:first, :conditions=>["request_id=?",filled_number(self.request_id,7)])
  end
end

