class SDPTask < ActiveRecord::Base

  attr_accessor :initial_should_be, :reevaluated_should_be, :difference

  def initialize
    super
    @initial_should_be      = 0.0
    @reevaluated_should_be  = 0.0
    @difference             = 0.0
  end

  # Analyze all sdpTasks and generate SDPphases/SDPActivities by specific types from RMT
  def self.formatStatsByType
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
        requestSdp = Request.find(sdpTask.request_id) 
        
        if ((requestSdp != nil) and (requestSdp.request_type != nil)) # With Specific type
          self.managePhase(sdpTask,requestSdp)
          self.manageActivity(sdpTask,requestSdp)
        elsif(requestSdp != nil) # With request but without specific type
          requestSdp.request_type = "Unclassed"
          self.managePhase(sdpTask,requestSdp)
          self.manageActivity(sdpTask,requestSdp)
        else  # Without request
          requestSdp.request_type = "Global"
          self.managePhase(sdpTask,requestSdp)
          self.manageActivity(sdpTask,requestSdp)
        end
      end
    }
  end
  
  # Generate SDPPhaseByType for the SDPtask given
  def self.managePhase(sdpTask,requestSdp)
    # identification of correct phase by name and request_type value
    phase = SDPPhase.find(sdpTask.phase_id)
    phaseByType = SDPPhaseByType.first(:conditions => ["title = ? AND request_type = ?", phase.title, requestSdp.request_type])
    if(phaseByType == nil)
      # Create
      phaseByType = SDPPhaseByType.new
      phaseByType.title = phase.title
      phaseByType.request_type = requestSdp.request_type
      phaseByType.initial = sdpTask.initial
      phaseByType.reevaluated = sdpTask.reevaluated
      phaseByType.assigned = sdpTask.assigned
      phaseByType.consumed = sdpTask.consumed
      phaseByType.remaining = sdpTask.remaining
      phaseByType.revised = sdpTask.revised
      phaseByType.gained = sdpTask.gained
      phaseByType.iteration = sdpTask.iteration
      phaseByType.collab = sdpTask.collab
      phaseByType.balancei = sdpTask.balancei
      phaseByType.balancer = sdpTask.balancer
      phaseByType.balancea = sdpTask.balancea
      phaseByType.save
    else
      # Add stats
      phaseByType.initial = phaseByType.initial + sdpTask.initial
      phaseByType.reevaluated = phaseByType.reevaluated + sdpTask.reevaluated
      phaseByType.assigned = phaseByType.assigned + sdpTask.assigned
      phaseByType.consumed = phaseByType.consumed + sdpTask.consumed
      phaseByType.remaining = phaseByType.remaining + sdpTask.remaining
      phaseByType.revised = phaseByType.revised + sdpTask.revised
      phaseByType.gained = phaseByType.gained + sdpTask.gained
      phaseByType.balancei = phaseByType.balancei + sdpTask.balancei
      phaseByType.balancer = phaseByType.balancer + sdpTask.balancer
      phaseByType.balancea = phaseByType.balancea + sdpTask.balancea
      phaseByType.save
    end
    sdpTask.phase_by_type_id = phaseByType.id
    sdpTask.save
  end
  
  # Generate SDPActivityByType for the SDPtask given
  def self.manageActivity(sdpTask,requestSdp)
    # identification of correct activity by name and request_type value
    activity = SDPActivity.find(sdpTask.activity_id)
    activityByType = SDPActivityByType.first(:conditions => ["title = ? AND request_type = ?", activity.title, requestSdp.request_type])
    if(activityByType == nil)
      # Create
      activityByType = SDPActivityByType.new
      activityByType.title = activity.title
      activityByType.request_type = requestSdp.request_type
      activityByType.phase_id = sdpTask.phase_by_type_id
      activityByType.initial = sdpTask.initial
      activityByType.reevaluated = sdpTask.reevaluated
      activityByType.assigned = sdpTask.assigned
      activityByType.consumed = sdpTask.consumed
      activityByType.remaining = sdpTask.remaining
      activityByType.revised = sdpTask.revised
      activityByType.gained = sdpTask.gained
      activityByType.iteration = sdpTask.iteration
      activityByType.collab = sdpTask.collab
      activityByType.balancei = sdpTask.balancei
      activityByType.balancer = sdpTask.balancer
      activityByType.balancea = sdpTask.balancea
      activityByType.save
    else
      # Add stats
      activityByType.initial = activityByType.initial + sdpTask.initial
      activityByType.reevaluated = activityByType.reevaluated + sdpTask.reevaluated
      activityByType.assigned = activityByType.assigned + sdpTask.assigned
      activityByType.consumed = activityByType.consumed + sdpTask.consumed
      activityByType.remaining = activityByType.remaining + sdpTask.remaining
      activityByType.revised = activityByType.revised + sdpTask.revised
      activityByType.gained = activityByType.gained + sdpTask.gained
      activityByType.balancei = activityByType.balancei + sdpTask.balancei
      activityByType.balancer = activityByType.balancer + sdpTask.balancer
      activityByType.balancea = activityByType.balancea + sdpTask.balancea
      activityByType.save
    end
    sdpTask.activity_by_type_id = activityByType.id
    sdpTask.save
  end
end

