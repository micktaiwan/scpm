module SdpDB

  PhaseDB = { # name => [phase_id, proposal_id]
	  'Bundle Management'=>[23738,22422],
	  'Continuous Improvement'=>[24121,22424],
	  'Quality Assurance'=>[23739,22423],
	  'WP1.1 - Quality Control'=>[23733,22053],
	  'WP1.2 - Quality Assurance'=>[23734,22053],
	  'WP2 - Quality for Maintenance'=>[24122,22054], # WP2 - Maintenance
	  'WP3 - Modeling'=>[23735,22055],
	  'WP4.1 - Surveillance Audit'=>[23736,22056], # does not exist in SDP (just WP4)
	  'WP4.2 - Surveillance Root cause'=>[23736,22056],
	  'WP5 - Change Accompaniment'=>[23737,22057],
	  'WP6.1 - Coaching PP'=>[24116,22058],     #WP6.1 - Coaching for Project setting-up
	  'WP6.2 - Coaching BRD'=>[24117,22058],    #WP6.2 - Coaching for Business Requirements
	  'WP6.3 - Coaching V&V'=>[24118,22058],    #WP6.3 - Coaching for Verification and Validation
	  'WP6.4 - Coaching for ConfMgt'=>[24119,22058],  #WP6.4 - Coaching for Configuration Management
	  'WP6.5 - Coaching Maintenance'=>[24120,22058]   #WP6.5 - Coaching for Maintenance
	  }

  ActivityDB = {
    ['All','WP3 - Modeling']=>102848,
    ['All','WP4.1 - Surveillance Audit']=>102850,
    ['All','WP4.2 - Surveillance Root cause']=>102850,
    ['All','WP6.1 - Coaching PP']=>102851,
    ['All','WP6.2 - Coaching BRD']=>102852,
    ['All','WP6.3 - Coaching V&V']=>102853,
    ['All','WP6.4 - Coaching for ConfMgt']=>102854,
    ['All','WP6.5 - Coaching Maintenance']=>102855,
    ['All','WP2 - Quality for Maintenance']=>102847,
    ['Audit',nil]=>102849,
    ['Bundle Management','']=>102846,
    ['Bundle Quality Assurance','']=>102856,
    ['Continuous Improvement','']=>105014,
    ['Hand-Over','']=>102845,
    ['Initialization','']=>102844,
    ['M1-M3','WP1.2 - Quality Assurance']=>102840,
    ['M1-M3','WP1.1 - Quality Control']=>102836,
    ['M3-M5','WP1.1 - Quality Control']=>102837,
    ['M3-M5','WP1.2 - Quality Assurance']=>102841,
    ['M5-M10','WP1.1 - Quality Control']=>102838,
    ['M5-M10','WP1.2 - Quality Assurance']=>102842,
    ['Montée en compétences',nil]=>108960,
    ['Operational Management',nil]=>107116,
    ['Post-M10','WP1.2 - Quality Assurance']=>102843,
    ['Post-M10','WP1.1 - Quality Control']=>102839,
    ['Processes Evaluation',nil]=>103037,
    ['Root Causes Analysis',nil]=>103036,
    ['Sous charges',nil]=>112058
    }

  DomainDB = {
    'EA'=>1581,
    'EV'=>1582,
    'EDE'=>1589,
    'EDY'=>1590,
    'EDG'=>1591,
    'EDS'=>1592,
    'EM'=>1593,
    'EI'=>1601,
    'EDC'=>1627,
    'EMNC'=>1777,
    'EMNB'=>2338
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

