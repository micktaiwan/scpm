class SDPTask < ActiveRecord::Base

  attr_accessor :initial_should_be, :reevaluated_should_be, :difference

  def initialize
    super
    @initial_should_be      = 0.0
    @reevaluated_should_be  = 0.0
    @difference             = 0.0
  end

  
  def self.formatStatsByType
    ActiveRecord::Base.connection.execute("TRUNCATE sdp_phases_by_type")
    ActiveRecord::Base.connection.execute("TRUNCATE sdp_activities_by_type")
    @allSdpTasks = SDPTask.find(:all)
     
    @allSdpTasks.each { |sdpTask|
      
      sdpTask.phase_by_type_id = nil
      sdpTask.activity_by_type_id = nil
      sdpTask.save
       
      # If we have a request id for this sdpTask
      if(sdpTask.request_id != nil)
         
        requestSdp = Request.find(sdpTask.request_id) 
         
        if ((requestSdp != nil) and (requestSdp.is_physical != nil))
          # Phase
          #if (sdpTask.phase_by_type_id == nil)
            self.managePhase(sdpTask,requestSdp)
          #end  
          # Activity
          #if (sdpTask.activity_by_type_id == nil)
            self.manageActivity(sdpTask,requestSdp)
          #end
        elsif(requestSdp != nil)
          # No request or is_physical to null
          requestSdp.is_physical = "Unclassed"
          self.managePhase(sdpTask,requestSdp)
          self.manageActivity(sdpTask,requestSdp)
        else  
          requestSdp.is_physical = "Global"
          self.managePhase(sdpTask,requestSdp)
          self.manageActivity(sdpTask,requestSdp)
        end
         
      end
    }
  end
  
  def self.managePhase(sdpTask,requestSdp)
    # identification of correct phase by name and is_physical value
    phase = SDPPhase.find(sdpTask.phase_id)
    phaseByType = SDPPhaseByType.first(:conditions => ["title = ? AND isPhysical = ?", phase.title, requestSdp.is_physical])
    if(phaseByType == nil)
      # Create
      phaseByType = SDPPhaseByType.new
      phaseByType.title = phase.title
      phaseByType.isPhysical = requestSdp.is_physical
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
  
  
  def self.manageActivity(sdpTask,requestSdp)
    # identification of correct activity by name and is_physical value
    activity = SDPActivity.find(sdpTask.activity_id)
    activityByType = SDPActivityByType.first(:conditions => ["title = ? AND isPhysical = ?", activity.title, requestSdp.is_physical])
    if(activityByType == nil)
      # Create
      activityByType = SDPActivityByType.new
      activityByType.title = activity.title
      activityByType.isPhysical = requestSdp.is_physical
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

