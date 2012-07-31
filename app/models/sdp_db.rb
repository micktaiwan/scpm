module SdpDB

  PhaseDB = { # name => [phase_id, proposal_id]
	  'Bundle Management'        =>[29255,28067],
	  'Continuous Improvement'   =>[29257,28068],
	  'Quality Assurance'        =>[29256,28069],
	  'WP1.1 - Quality Control'  =>[29244,28061],
	  'WP1.2 - Quality Assurance'=>[29245,28061],
    'WP1.3 - Quality Control + BAT'=>[29633,28061],
    'WP1.4 - Quality Assurance + BAT'=>[29634,28061],
	  'WP2 - Quality for Maintenance'=>[29246,28062], # WP2 - Maintenance
    'WP3.0 - Old Modeling'            => [29247,28063],
    'WP3.1 - Modeling Support'        => [29247,28063],
    'WP3.2 - Modeling Conception and Production' => [29247,28063],
    'WP3.3 - Modeling BAT specific Control'      => [29247,28063],
    'WP3.4 - Modeling BAT specific Production'   => [29247,28063],
	  'WP3 - Modeling'=>[29247,28063],
	  'WP4.1 - Surveillance Audit'=>[29248,28064], # does not exist in SDP (just WP4)
	  'WP4.2 - Surveillance Root cause'=>[29248,28064],
	  'WP5 - Change Accompaniment'=>[29249,28065],
	  'WP6.1 - Coaching PP'=>[29250,28066],     #WP6.1 - Coaching for Project setting-up
	  'WP6.2 - Coaching BRD'=>[29251,28066],    #WP6.2 - Coaching for Business Requirements
	  'WP6.3 - Coaching V&V'=>[29252,28066],    #WP6.3 - Coaching for Verification and Validation
	  'WP6.4 - Coaching ConfMgt'=>[29253,28066],  #WP6.4 - Coaching for Configuration Management
	  'WP6.5 - Coaching Maintenance'=>[29254,28066]   #WP6.5 - Coaching for Maintenance
	  }

  ActivityDB = {
    ['All','WP3.0 - Old Modeling']=>127636,
    ['All','WP3.1 - Modeling Support']=>127636,
    ['All','WP3.2 - Modeling Conception and Production']=>127636,
    ['All','WP3.3 - Modeling BAT specific Control']=>127636,
    ['All','WP3.4 - Modeling BAT specific Production']=>127636,
    ['All','WP3 - Modeling']=>127636,
    ['All','WP4.1 - Surveillance Audit']=>127637,
    ['All','WP4.2 - Surveillance Root cause']=>127638,
    ['All','WP5 - Change Accompaniment']=>127640,
    ['All','WP6.1 - Coaching PP']=>127641,
    ['All','WP6.2 - Coaching BRD']=>127642,
    ['All','WP6.3 - Coaching V&V']=>127643,
    ['All','WP6.4 - Coaching ConfMgt']=>127644,
    ['All','WP6.5 - Coaching Maintenance']=>127645,
    ['All','WP2 - Quality for Maintenance']=>127635,
    #['Audit',nil]=>127637,
    ['Bundle Management','']=>127647,
    ['Bundle Quality Assurance','']=>127646,
    ['Continuous Improvement','']=>127648,
    #['Hand-Over','']=>102845,
    #['Initialization','']=>102844,
    ['M1-M3','WP1.2 - Quality Assurance']=>127631,
    ['M1-M3','WP1.1 - Quality Control']=>127627,
    ['M3-M5','WP1.1 - Quality Control']=>127628,
    ['M3-M5','WP1.2 - Quality Assurance']=>127632,
    ['M5-M10','WP1.1 - Quality Control']=>127629,
    ['M5-M10','WP1.2 - Quality Assurance']=>127633,
    ['Montée en compétences',nil]=>127650,
    ['Operational Management',nil]=>127649,
    ['Post-M10','WP1.2 - Quality Assurance']=>127634,
    ['Post-M10','WP1.1 - Quality Control']=>127630,
    ['Processes Evaluation',nil]=>127639,
    ['Root Causes Analysis',nil]=>127638,
    ['Sous charges',nil]=>127651
    }

  # SDP Doamin
  DomainDB = {
    #'EA'  =>2865,
    'EV'  =>2866,
    'EE' =>2867,
    'EY' =>2868,
    'EG' =>2869,
    'ES' =>2870,
    'EZ'  =>2872,
    'EI'  =>2873,
    'EZC' =>2871,
    'EZMC'=>2860,
    'EZMB'=>2861,
    'TBCE' => 3213
    }

  def self.sdp_phase_id(name)
    rv = PhaseDB[name]
    raise "SDPPhase '#{name}' unknown" if not rv
    rv[0]
  end

  def self.sdp_proposal_id(name)
    rv = PhaseDB[name]
    raise "Proposal '#{name}' unknown" if not rv
    rv[1]
  end

  def self.sdp_domain_id(name)
    rv = DomainDB[name]
    raise "Domain '#{name}' unknown" if not rv
    rv
  end

  def self.sdp_activity_id(arr)
    rv = ActivityDB[[arr[0],nil]]
    rv = ActivityDB[arr] if not rv
    raise "SDPActivity '[#{arr.join(',')}]' unknown" if not rv
    rv
  end

end

