class WlLine < ActiveRecord::Base
  has_many :wl_loads

  def load_by_week(week)
    WlLoad.find(:first, :conditions=>["wl_line_id=? and week=?", self.id, week])
  end

  def get_load_by_week(week)
    l = load_by_week(week)
    l ? l.wlload : 0.0
  end


  def display_name
    "<a href='#' title='#{self.name}'>#{name}</a>"
  end
end

