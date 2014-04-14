module SdpDB

  PhaseDB = { # name => [phase_id, proposal_id]
	  'Bundle Management'        =>[35706,34939],#
    'Continuous Improvement'   =>[35708,34940],#
    'Quality Assurance'        =>[35707,34941],#
    'Provisions'			         =>[35709,34942],#
    'WP1.1 - Quality Control'  =>[35710,34863],#
    'WP1.2 - Quality Assurance'=>[35711,34863],#
    'WP1.3 - BAT'=>[35712,34863],#
    'WP1.4 - Quality Assurance + BAT'=>[29634,34863], # Not used anymore # ?
    'WP1.4 - Agility'          =>[35779,34863], #
    'WP1.5 - SQR'              =>[35780,34863], #
    'WP1.6.1 - QWR DWQAP'          =>[35781,34863], #
    'WP1.6.2 - QWR Project Setting-up' =>[35782,34863], #
    'WP1.6.3 - QWR Support, Reporting & KPI' =>[35783,34863], #
    'WP1.6.4 - QWR Quality Status'          =>[35784,34863], #
    'WP1.6.5 - QWR Spiders'                 =>[35785,34863], #
    'WP1.6.6 - QWR QG BRD'                  =>[35786,34863], #
    'WP1.6.7 - QWR QG TD'                   =>[35787,34863], #
    'WP1.6.8 - QWR Lessons Learnt'          =>[35788,34863], #
    'WP2 - Quality for Maintenance'=>[35789,34864], # WP2 - Maintenance
    'WP3.0 - Old Modeling'            => [35790,34865], #
    'WP3 - Modeling'                  =>[35790,34865], #
    'WP3.1 - Modeling Support'        => [35791,34865], #
    'WP3.2 - Modeling Conception and Production' => [35792,34865], #
    'WP3.2.1 - Business Process Layout'          => [35792,34865], #
    'WP3.2.2 - Functional Layout (Use Cases)'    => [35793,34865], #
    'WP3.2.3 - Information Layout (Data Model)'  => [35794,34865], #
    'WP3.3 - Modeling BAT specific Control'      => [35795,34865], #
    'WP3.4 - Modeling BAT specific Production'   => [35796,34865], #
    'WP4.1 - Surveillance Audit'=>[35798,34866], #
    'WP4.2 - Surveillance Root cause'=>[35799,34866], #
    'WP4.3 - Actions Implementation & Control'   => [35800,34866], #
    'WP4.4 - Fast Root Cause Analysis' => [35801, 34866], #2014
    'WP5 - Change Accompaniment'=>[35802,34867], #
    'WP5.1 - Change: Diagnosis & Action Plan'    => [35803,34867], #
    'WP5.2 - Change : Implementation Support & Follow-up' => [35804,34867], #
    'WP6.1 - Coaching PP'=>[35805,34868],     #
    'WP6.2 - Coaching BRD'=>[35806,34868],    #
    'WP6.3 - Coaching V&V'=>[35807,34868],    #
    'WP6.4 - Coaching ConfMgt'=>[35808,34868],  #
    'WP6.5 - Coaching Maintenance'=>[35809,34868],   #
    "WP6.6 - Coaching HLR" => [35810,34868], #
    "WP6.7 - Coaching Business Process"                   => [35811,34868], #
    "WP6.8 - Coaching Use Case"                           => [35812,34868], #
    "WP6.9 - Coaching Data Model"                         => [35813,34868], #
    "WP6.10.1 - Coaching Agility: Diagnosis & project launch"   => [35814,34868], #
    "WP6.10.2 - Coaching Agility: Sprint 0 support"             => [35815,34868], #
    "WP6.10.3 - Coaching Agility: Sprint coaching"              => [35816,34868], #
    'WP6.11 - Coaching Risks Management'                        => [35817,34868], #2014
    'WP7.1 - Light Expertise'                                   => [35818,34869], #2014
    'WP7.2 - Complete Expertise'                                => [35825,34869], #2014
    "WP7.1.1 - Expertise Activities for Multi Projects: Requirements Management"      => [35819,34869], #
    "WP7.1.2 - Expertise Activities for Multi Projects: Risks Management"             => [35820,34869], #
    "WP7.1.3 - Expertise Activities for Multi Projects: Test Management"              => [35821,34869], #
    "WP7.1.4 - Expertise Activities for Multi Projects: Change Management"            => [35822,34869], #
    "WP7.1.5 - Expertise Activities for Multi Projects: Lessons Learnt"               => [35823,34869], #
    "WP7.1.6 - Expertise Activities for Multi Projects: Configuration Management"     => [35824,34869], #
    "WP7.2.1 - Expertise Activities for Multi Projects: Requirements Management"      => [35826,34869], #
    "WP7.2.2 - Expertise Activities for Multi Projects: Risks Management"             => [35827,34869], #
    "WP7.2.3 - Expertise Activities for Multi Projects: Test Management"              => [35828,34869], #
    "WP7.2.4 - Expertise Activities for Multi Projects: Change Management"            => [35829,34869], #
    "WP7.2.5 - Expertise Activities for Multi Projects: Lessons Learnt"               => [35830,34869], #
    "WP7.2.6 - Expertise Activities for Multi Projects: Configuration Management"     => [35831,34869]  #
  }


    #[milestone, WP] = ID activity
    ActivityDB = {
      # WP1.1
      ['M1-M3','WP1.1 - Quality Control']=>158133,
      ['M3-M5','WP1.1 - Quality Control']=>158134,
      ['M5-M10','WP1.1 - Quality Control']=>158135,
      ['Post-M10','WP1.1 - Quality Control']=>158136,
      # WP 1.2
      ['M1-M3','WP1.2 - Quality Assurance']=>158137,
      ['M3-M5','WP1.2 - Quality Assurance']=>158138,
      ['M5-M10','WP1.2 - Quality Assurance']=>158139,
      ['Post-M10','WP1.2 - Quality Assurance']=>158140,
      # WP 1.3
      ['M3-M5','WP1.3 - BAT']=>158141,
      ['M5-M10','WP1.3 - BAT']=>158142,
      ['Post-M10','WP1.3 - BAT']=>158143,
      # WP 1.4
      ['M3-M5','WP1.4 - Agility']=>158144,
      ['M5-M10','WP1.4 - Agility']=>158145,
      ['Post-M10','WP1.4 - Agility']=>158146,
      # WP 1.5
      ['M1-M3','WP1.5 - SQR']=>158147,
      ['M3-M5','WP1.5 - SQR']=>158148,
      ['M5-M10','WP1.5 - SQR']=>158149,
      ['Post-M10','WP1.5 - SQR']=>158150,
      # WP 1.6.1
      ['All','WP1.6.1 - QWR DWQAP']=>158151,
      # WP 1.6.2
      ['All','WP1.6.2 - QWR Project Setting-up']=>158152,
      # WP 1.6.3
      ['All','WP1.6.3 - QWR Support, Reporting & KPI']=>158153,
      # WP 1.6.4
      ['All','WP1.6.4 - QWR Quality Status']=>158154,
      # WP 1.6.5
      ['All','WP1.6.5 - QWR Spiders']=>158155,
      # WP 1.6.6
      ['All','WP1.6.6 - QWR QG BRD']=>158156,
      # WP 1.6.7
      ['All','WP1.6.7 - QWR QG TD']=>158157,
      # WP 1.6.8
      ['All','WP1.6.8 - QWR Lessons Learnt']=>158158,
      
      # WP 2
      ['All','WP2 - Quality for Maintenance']=>158159,
      
      # WP 3
      ['All','WP3.0 - Old Modeling']=>158466,                         
      ['All','WP3 - Modeling']=>158466, 
      ['All','WP3.1 - Modeling Support']=>158160,
      ['All','WP3.2 - Modeling Conception and Production']=>158466,   
      ['All','WP3.2.1 - Business Process Layout']=>158161,
      ['All','WP3.2.2 - Functional Layout (Use Cases)']=>158162,
      ['All','WP3.2.3 - Information Layout (Data Model)']=>158163,
      ['All','WP3.3 - Modeling BAT specific Control']=>158164,
      ['All','WP3.4 - Modeling BAT specific Production']=>158165,
      
      # WP 4
      ['All','WP4.1 - Surveillance Audit']=>158503,
      ['All','WP4.2 - Surveillance Root cause']=>158504,
      ['All','WP4.3 - Actions Implementation & Control']=>158505,
      ['All','WP4.4 - Fast Root Cause Analysis']=>158506, # 2014
      
      # WP 5
      ['All','WP5 - Change Accompaniment']=>158507,
      ['All','WP5.1 - Change: Diagnosis & Action Plan']=>158508,
      ['All','WP5.2 - Change : Implementation Support & Follow-up']=>158509,
      
      # WP 6
      ['All','WP6.1 - Coaching PP']=>158510,
      ['All','WP6.2 - Coaching BRD']=>158511,
      ['All','WP6.3 - Coaching V&V']=>158512,
      ['All','WP6.4 - Coaching ConfMgt']=>158513,
      ['All','WP6.5 - Coaching Maintenance']=>158514,
      ['All','WP6.6 - Coaching HLR']=>158515,
      ['All','WP6.7 - Coaching Business Process']=>158516,
      ['All','WP6.8 - Coaching Use Case']=>158517,
      ['All','WP6.9 - Coaching Data Model']=>158518,
      ['All','WP6.10.1 - Coaching Agility: Diagnosis & project launch']=>158519,
      ['All','WP6.10.2 - Coaching Agility: Sprint 0 support']=>158520,
      ['All','WP6.10.3 - Coaching Agility: Sprint coaching']=>158521,
      ['All','WP6.11 - Coaching Risks Management']=>158522, # 2014
      
      # WP 7
      ['All','WP7.1 - Light Expertise']=>158523, # 2014
      ['All','WP7.1.1 - Expertise Activities for Multi Projects: Requirements Management']=>158524, 
      ['All','WP7.1.2 - Expertise Activities for Multi Projects: Risks Management']=>158525,
      ['All','WP7.1.3 - Expertise Activities for Multi Projects: Test Management']=>158526,		 
      ['All','WP7.1.4 - Expertise Activities for Multi Projects: Change Management']=>158527,		 
      ['All','WP7.1.5 - Expertise Activities for Multi Projects: Lessons Learnt']=>158528,		 
      ['All','WP7.1.6 - Expertise Activities for Multi Projects: Configuration Management']=>158529,		 
      ['All','WP7.2 - Complete Expertise']=>158530, # 2014
      ['All','WP7.2.1 - Expertise Activities for Project: Requirements Management']=>158531,		 
      ['All','WP7.2.2 - Expertise Activities for Project: Risks Management']=>158532,		 
      ['All','WP7.2.3 - Expertise Activities for Project: Test Management']=>158533,		 
      ['All','WP7.2.4 - Expertise Activities for Project: Change Management']=>158534,		 
      ['All','WP7.2.5 - Expertise Activities for Project: Lessons Learnt']=>158535,		 
      ['All','WP7.2.6 - Expertise Activities for Project: Configuration Management']=>158536,
      
      # BUNDLE MANAGEMENT
      ['Bundle Management','']=>158538,
      ['Bundle Quality Assurance','']=>158537,
      ['Operational Management',nil]=>158540,
      ['Montée en compétences',nil]=>158541,
      ['Continuous Improvement','']=>158539,
      ['Sous charges',nil]=>158542,
      
      # WP4
      ['Processes Evaluation',nil]=>158166,
      ['Root Causes Analysis',nil]=>158167
      }

  # SDP Doamin
  DomainDB = {
      'EV'  =>4455,
      'EP'  =>4454,
      'EY'  =>4457,
      'EG'  =>4464,
      'ES'  =>4456,
      'EZ'  =>4458,
      'EI'  =>4460,
      'EZC' =>4459,
      'EZMC'=>4461,
      'EZMB'=>4462,
      'EC'  =>4463
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

