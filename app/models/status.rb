class Status < ActiveRecord::Base

  belongs_to :project
  belongs_to :modifier, :class_name=>'Person', :foreign_key=>'last_modifier'
  has_many   :history_counters

  before_save :escape

  def is_current?
    self.updated_at.to_date.cweek == Date.today.cweek
  end

  def get_last_change_excel
    return self.last_change_excel if self.last_change_excel
    self.last_change
  end

  def escape
    self.reason       = html_escape(self.reason)
    self.explanation  = html_escape(self.explanation)
    self.last_change  = html_escape(self.last_change)
    self.ws_report    = html_escape(self.ws_report)
    self.feedback     = html_escape(self.feedback)
    self.actions      = html_escape(self.actions)
    self.operational_alert = html_escape(self.operational_alert)
  end

  def copy_status_to_ws_reporting
    Status.record_timestamps  = false
    self.ws_report      = self.reason
    self.ws_updated_at  = self.reason_updated_at
    self.save
    Status.record_timestamps  = true
  end

end

