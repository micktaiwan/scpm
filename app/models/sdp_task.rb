class SDPTask < ActiveRecord::Base

  attr_accessor :initial_should_be, :reevaluated_should_be, :difference

  def initialize
    super
    @initial_should_be      = 0.0
    @reevaluated_should_be  = 0.0
    @difference             = 0.0
  end

  def project
    return nil if !self.project_code
    Project.find_by_project_code(self.project_code)
  end

  def project_name
    p = self.project
    if p
      "#{p.name} (#{p.project_code})"
    else
      "can't find project for '#{self.project_code}'"
    end
  end

  # Analyze all sdpTasks and generate SDPphases/SDPActivities by specific types from RMT
  def self.format_stats_by_type
    # Reset data
    ActiveRecord::Base.connection.execute("TRUNCATE sdp_phases_by_type")
    ActiveRecord::Base.connection.execute("TRUNCATE sdp_activities_by_type")
    
    @allSdpTasks = SDPTask.find(:all) 
    @allSdpTasks.each { |sdpTask|
      # Reset params of the task
      sdpTask.phase_by_type_id = nil
      sdpTask.activity_by_type_id = nil
      sdpTask.save
       
      # If we have a request id for this sdpTask
      if(sdpTask.request_id != nil)
        requestSdp = Request.find(:first, :conditions => { :request_id => sdpTask.request_id })
        if (requestSdp != nil)
          if (requestSdp.request_type != nil)
            self.manage_phase(sdpTask,requestSdp)
            self.manage_activity(sdpTask,requestSdp)
          else
            requestSdp.request_type = "no_type"
            self.manage_phase(sdpTask,requestSdp)
            self.manage_activity(sdpTask,requestSdp)
          end
        # else
          # requestSdp = Request.new()
          # requestSdp.request_type = "Unclassed"
          # self.manage_phase(sdpTask,requestSdp)
          # self.manage_activity(sdpTask,requestSdp)
        end
      end
    }
  end
  
  # Generate SDPPhaseByType for the SDPtask given
  def self.manage_phase(sdpTask,requestSdp)
    # identification of correct phase by name and request_type value
    phase = SDPPhase.find(:first, :conditions => { :id => sdpTask.phase_id })
    if ((phase != nil) and (sdpTask != nil))
      phaseByType = SDPPhaseByType.first(:conditions => ["title = ? AND request_type = ?", phase.title, requestSdp.request_type])
      if(phaseByType == nil)
        # Create
        phaseByType = SDPPhaseByType.new
        phaseByType.title = phase.title
        phaseByType.request_type = requestSdp.request_type
        phaseByType.initial = self.field_is_null(sdpTask.initial)
        phaseByType.reevaluated = self.field_is_null(sdpTask.reevaluated)
        phaseByType.assigned = self.field_is_null(sdpTask.assigned)
        phaseByType.consumed = self.field_is_null(sdpTask.consumed)
        phaseByType.remaining = self.field_is_null(sdpTask.remaining)
        phaseByType.revised = self.field_is_null(sdpTask.revised)
        phaseByType.gained = self.field_is_null(sdpTask.gained)
        phaseByType.iteration = self.field_is_null(sdpTask.iteration)
        phaseByType.collab = self.field_is_null(sdpTask.collab)
        phaseByType.balancei = self.field_is_null(sdpTask.balancei)
        phaseByType.balancer = self.field_is_null(sdpTask.balancer)
        phaseByType.balancea = self.field_is_null(sdpTask.balancea)
        phaseByType.save
      else
        # Add stats
        phaseByType.initial = phaseByType.initial + self.field_is_null(sdpTask.initial)
        phaseByType.reevaluated = phaseByType.reevaluated + self.field_is_null(sdpTask.reevaluated)
        phaseByType.assigned = phaseByType.assigned + self.field_is_null(sdpTask.assigned)
        phaseByType.consumed = phaseByType.consumed + self.field_is_null(sdpTask.consumed)
        phaseByType.remaining = phaseByType.remaining + self.field_is_null(sdpTask.remaining)
        phaseByType.revised = phaseByType.revised + self.field_is_null(sdpTask.revised)
        phaseByType.gained = phaseByType.gained + self.field_is_null(sdpTask.gained)
        phaseByType.balancei = phaseByType.balancei + self.field_is_null(sdpTask.balancei)
        phaseByType.balancer = phaseByType.balancer + self.field_is_null(sdpTask.balancer)
        phaseByType.balancea = phaseByType.balancea + self.field_is_null(sdpTask.balancea)
        phaseByType.save
      end
      sdpTask.phase_by_type_id = phaseByType.id
      sdpTask.save
    end
  end
  
  # Generate SDPActivityByType for the SDPtask given
  def self.manage_activity(sdpTask,requestSdp)
    # identification of correct activity by name and request_type value
    activity = SDPActivity.find(:first, :conditions => { :id => sdpTask.activity_id })
    if ((activity != nil) and (sdpTask != nil))
      activityByType = SDPActivityByType.first(:conditions => ["title = ? AND request_type = ?", activity.title, requestSdp.request_type])
      if(activityByType == nil)
        # Create
        activityByType = SDPActivityByType.new
        activityByType.title = activity.title
        activityByType.request_type = requestSdp.request_type
        activityByType.phase_id = self.field_is_null(sdpTask.phase_by_type_id)
        activityByType.initial = self.field_is_null(sdpTask.initial)
        activityByType.reevaluated = self.field_is_null(sdpTask.reevaluated)
        activityByType.assigned = self.field_is_null(sdpTask.assigned)
        activityByType.consumed = self.field_is_null(sdpTask.consumed)
        activityByType.remaining = self.field_is_null(sdpTask.remaining)
        activityByType.revised = self.field_is_null(sdpTask.revised)
        activityByType.gained = self.field_is_null(sdpTask.gained)
        activityByType.iteration = self.field_is_null(sdpTask.iteration)
        activityByType.collab = self.field_is_null(sdpTask.collab)
        activityByType.balancei = self.field_is_null(sdpTask.balancei)
        activityByType.balancer = self.field_is_null(sdpTask.balancer)
        activityByType.balancea = self.field_is_null(sdpTask.balancea)
        activityByType.save
      else
        # Add stats
        activityByType.initial = activityByType.initial + self.field_is_null(sdpTask.initial)
        activityByType.reevaluated = activityByType.reevaluated + self.field_is_null(sdpTask.reevaluated)
        activityByType.assigned = activityByType.assigned + self.field_is_null(sdpTask.assigned)
        activityByType.consumed = activityByType.consumed + self.field_is_null(sdpTask.consumed)
        activityByType.remaining = activityByType.remaining + self.field_is_null(sdpTask.remaining)
        activityByType.revised = activityByType.revised + self.field_is_null(sdpTask.revised)
        activityByType.gained = activityByType.gained + self.field_is_null(sdpTask.gained)
        activityByType.balancei = activityByType.balancei + self.field_is_null(sdpTask.balancei)
        activityByType.balancer = activityByType.balancer + self.field_is_null(sdpTask.balancer)
        activityByType.balancea = activityByType.balancea + self.field_is_null(sdpTask.balancea)
        activityByType.save
      end
      sdpTask.activity_by_type_id = activityByType.id
      sdpTask.save
    end
  end
  
  def self.field_is_null(fieldValue)
    if(fieldValue)
      return fieldValue
    else
      return 0
    end
  end
  
end

