module SdpDB

  PhaseDB = { # name => [phase_id, proposal_id]
	  'Bundle Management'        =>[32329,31245],
    'Continuous Improvement'   =>[32331,31375],
    'Quality Assurance'        =>[32330,31376],
    'Provisions'			   =>[32332,]
    'WP1.1 - Quality Control'  =>[32317,31244],
    'WP1.2 - Quality Assurance'=>[32318,31244],
    'WP1.3 - Quality Control + BAT'=>[32319,31244],
    'WP1.4 - Quality Assurance + BAT'=>[29634,31244], # Not used anymore # ?
    'WP1.4 - Agility'          =>[32488,31244], #NEW
    'WP1.5 - SQR'              =>[32497,31244], #NEW
    'WP1.6.1 - DWQAP'          =>[32498,31244], #NEW
    'WP1.6.2 - Project Setting-up' =>[32498,31244], #NEW
    'WP1.6.3 - Support, Reporting & KP' =>[32498,31244], #NEW
    'WP1.6.4 – Quality Status'          =>[32498,31244], #NEW
    'WP1.6.5 – Spiders'                 =>[32498,31244], #NEW
    'WP1.6.6 – QG BRD'                  =>[32498,31244], #NEW
    'WP1.6.7 – QG TD'                   =>[32498,31244], #NEW
    'WP1.6.8 – Lessons Learnt'          =>[32498,31244], #NEW
    'WP2 - Quality for Maintenance'=>[32320,31246], # WP2 - Maintenance
    'WP3.0 - Old Modeling'            => [32321,31247],
    'WP3 - Modeling'=>[32321,31247],
    'WP3.1 - Modeling Support'        => [32321,31247],
    'WP3.2 - Modeling Conception and Production' => [32321,31247],
    'WP3.2.1 - Business Process Layout'          => [32321,31247], #NEW
    'WP3.2.2 - Functional Layout (Use Cases)'    => [32321,31247], #NEW
    'WP3.2.3 - Information Layout (Data Model)'  => [32321,31247], #NEW
    'WP3.3 - Modeling BAT specific Control'      => [32321,31247],
    'WP3.4 - Modeling BAT specific Production'   => [32321,31247],
    'WP4.1 - Surveillance Audit'=>[32322,31248], # does not exist in SDP (just WP4)
    'WP4.2 - Surveillance Root cause'=>[32322,31248],
    'WP4.3 - Actions Implementation & Control'   => [32322,31248], #NEW
    'WP5 - Change Accompaniment'=>[32323,31249],
    'WP5.1 - Change: Diagnosis & Action Plan'    => [32323,31249], #NEW
    'WP5.2 – Change : Implementation Support & Follow-up' => [32323,31249], #NEW
    'WP6.1 - Coaching PP'=>[32324,31250],     #WP6.1 - Coaching for Project setting-up
    'WP6.2 - Coaching BRD'=>[32325,31250],    #WP6.2 - Coaching for Business Requirements
    'WP6.3 - Coaching V&V'=>[32326,31250],    #WP6.3 - Coaching for Verification and Validation
    'WP6.4 - Coaching ConfMgt'=>[32327,31250],  #WP6.4 - Coaching for Configuration Management
    'WP6.5 - Coaching Maintenance'=>[32328,31250]   #WP6.5 - Coaching for Maintenance
    "WP6.6 – Change : Implementation Support & Follow-up" => [32499,31250], #NEW
    "WP6.7 – Coaching Business Process"                   => [32500,31250], #NEW
    "WP6.8 – Coaching Use Case"                           => [32501,31250], #NEW
    "WP6.9 – Coaching Data Model"                         => [32502,31250], #NEW
    "WP6.10.1 – Diagnosis & project launch"               => [32503,31250], #NEW
    "WP6.10.2 – Sprint 0 support"                         => [32503,31250], #NEW
    "WP6.10.3 – Sprint coaching"                          => [32503,31250], #NEW
    "WP7.1.1 – Requirements Management"                   => [32489,31568], #NEW
    "WP7.1.2 – Risks Management"                          => [32489,31568], #NEW
    "WP7.1.3 – Test Management"                           => [32489,31568], #NEW
    "WP7.1.4 – Change Management"                         => [32489,31568], #NEW
    "WP7.1.5 – Lessons Learnt"                            => [32489,31568], #NEW
    "WP7.1.6 – Configuration Management"                  => [32489,31568], #NEW
    "WP7.2.1 – Requirements Management"                   => [32504,31568], #NEW
    "WP7.2.2 – Risks Management"                          => [32504,31568], #NEW
    "WP7.2.3 – Test Management"                           => [32504,31568], #NEW
    "WP7.2.4 – Change Management"                         => [32504,31568], #NEW
    "WP7.2.5 – Lessons Learnt"                            => [32504,31568], #NEW
    "WP7.2.6 – Configuration Management"                  => [32504,31568]  #NEW
  }


    #[milestone, WP] = ID activity
    ActivityDB = {
      # WP1.1
      ['M1-M3','WP1.1 - Quality Control']=>142217,
      ['M3-M5','WP1.1 - Quality Control']=>142218,
      ['M5-M10','WP1.1 - Quality Control']=>142219,
      ['Post-M10','WP1.1 - Quality Control']=>142220,
      # WP 1.2
      ['M1-M3','WP1.2 - Quality Assurance']=>142221,
      ['M3-M5','WP1.2 - Quality Assurance']=>142222,
      ['M5-M10','WP1.2 - Quality Assurance']=>142223,
      ['Post-M10','WP1.2 - Quality Assurance']=>142224,
      # WP 1.3
      # WP 1.4
      ['M3-M5','WP1.4 - Agility']=>143003,
      ['M5-M10','WP1.4 - Agility']=>143004,
      ['Post-M10','WP1.4 - Agility']=>143005,
      # WP 1.5
      ['M1-M3','WP1.5 - SQR']=>143042,
      ['M3-M5','WP1.5 - SQR']=>143043,
      ['M5-M10','WP1.5 - SQR']=>143044,
      ['Post-M10','WP1.5 - SQR']=>143045,
      # WP 1.6.1
      ['All','WP1.6.1 - QWR DWQAP']=>143046,
      # WP 1.6.2
      ['All','WP1.6.2 - QWR Project Setting-up']=>143047,
      # WP 1.6.3
      ['All','WP1.6.3 - QWR Support, Reporting & KPI']=>143048,
      # WP 1.6.4
      ['All','WP1.6.4 - QWR Quality Status']=>143049,
      # WP 1.6.5
      ['All','WP1.6.5 - QWR Spiders']=>143050,
      # WP 1.6.6
      ['All','WP1.6.6 - QWR QG BRD']=>143051,
      # WP 1.6.7
      ['All','WP1.6.7 - QWR QG TD']=>143052,
      # WP 1.6.8
      ['All','WP1.6.8 - QWR Lessons Learnt']=>143053,
      
      # WP 2
      ['All','WP2 - Quality for Maintenance']=>142225,
      
      # WP 3
      ['All','WP3.0 - Old Modeling']=>142226,                         
      ['All','WP3 - Modeling']=>142226, 
      ['All','WP3.1 - Modeling Support']=>143054,
      ['All','WP3.2 - Modeling Conception and Production']=>142226,   
      ['All','WP3.2.1 - Business Process Layout']=>143055,
      ['All','WP3.2.2 - Functional Layout (Use Cases)']=>143056,
      ['All','WP3.2.3 - Information Layout (Data Model)']=>143057,
      ['All','WP3.3 - Modeling BAT specific Control']=>143058,
      ['All','WP3.4 - Modeling BAT specific Production']=>143059,
      
      # WP 4
      ['All','WP4.1 - Surveillance Audit']=>142227,
      ['All','WP4.2 - Surveillance Root cause']=>142228,
      ['All','WP4.3 - Actions Implementation & Control']=>142229,
      
      # WP 5
      ['All','WP5 - Change Accompaniment']=>142230,
      ['All','WP5.1 - Change: Diagnosis & Action Plan']=>143060,
      ['All','WP5.2 - Change : Implementation Support & Follow-up']=>143061,
      
      # WP 6
      ['All','WP6.1 - Coaching PP']=>142231,
      ['All','WP6.2 - Coaching BRD']=>142232,
      ['All','WP6.3 - Coaching V&V']=>142233,
      ['All','WP6.4 - Coaching ConfMgt']=>142234,
      ['All','WP6.5 - Coaching Maintenance']=>142235,
      ['All','WP6.6 - Coaching HLR']=>143062,
      ['All','WP6.7 - Coaching Business Process']=>143063,
      ['All','WP6.8 - Coaching Use Case']=>143064,
      ['All','WP6.9 - Coaching Data Model']=>143065,
      ['All','WP6.10.1 - Coaching Agility: Diagnosis & project launch']=>143066,
      ['All','WP6.10.2 - Coaching Agility: Sprint 0 support']=>143067,
      ['All','WP6.10.3 - Coaching Agility: Sprint coaching']=>143068,
      
      # WP 7
      ['All','WP7.1.1 - Expertise Activities for Multi Projects: Requirements Management']=>143006, 
      ['All','WP7.1.2 - Expertise Activities for Multi Projects: Risks Management']=>143069,
      ['All','WP7.1.3 - Expertise Activities for Multi Projects: Test Management']=>143070,		 
      ['All','WP7.1.4 - Expertise Activities for Multi Projects: Change Management']=>143071,		 
      ['All','WP7.1.5 - Expertise Activities for Multi Projects: Lessons Learnt']=>143072,		 
      ['All','WP7.1.6 - Expertise Activities for Multi Projects: Configuration Management']=>143073,		 
      ['All','WP7.2.1 - Expertise Activities for Project: Requirements Management']=>143074,		 
      ['All','WP7.2.2 - Expertise Activities for Project: Risks Management']=>143075,		 
      ['All','WP7.2.3 - Expertise Activities for Project: Test Management']=>143076,		 
      ['All','WP7.2.4 - Expertise Activities for Project: Change Management']=>143077,		 
      ['All','WP7.2.5 - Expertise Activities for Project: Lessons Learnt']=>143078,		 
      ['All','WP7.2.6 - Expertise Activities for Project: Configuration Management']=>143079,
      
      # BUNDLE MANAGEMENT
      ['Bundle Management','']=>142237,
      ['Bundle Quality Assurance','']=>142236,
      ['Operational Management',nil]=>142239,
      ['Montée en compétences',nil]=>142240,
      ['Continuous Improvement','']=>142238,
      ['Sous charges',nil]=>142241,
      
      # WP4
      ['Processes Evaluation',nil]=>143222,
      ['Root Causes Analysis',nil]=>142228
      }

  # SDP Doamin
  DomainDB = {
      #'EA'  =>2865,
      'EV'  =>3734,
      'EE'  =>3733,
      'EY'  =>3736,
      'EG'  =>3743,
      'ES'  =>3735,
      'EZ'  =>3737,
      'EI'  =>3739,
      'EZC' =>3738,
      'EZMC'=>3740,
      'EZMB'=>3741,
      'TBCE'=>3742
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
    rv = ActivityDB[[arr[0],nil]] # SI [milestone,nil]
    rv = ActivityDB[arr] if not rv # Si pas [milestone,nil] alors on prend [milestone,Workpackage]
    raise "SDPActivity '[#{arr.join(',')}]' unknown" if not rv
    rv
  end

end

