class VirtualWlLine < WlLine

  attr_accessor :projects, :sdp_tasks, :number, :alert_sdp_task

  def initialize
    super
    @projects   = Array.new
    @sdp_tasks  = Array.new
    @number     = 1
    @alert_sdp_task = false
  end

end