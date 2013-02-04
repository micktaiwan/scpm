class Request < ActiveRecord::Base

  belongs_to :project
  belongs_to :stream
  has_one    :wl_line, :primary_key=>"request_id"
  has_one    :counter_log, :dependent=>:nullify
  has_many   :history_counters, :dependent=>:nullify
  # belongs_to :resp, :class_name=>'Person', :conditions=>"assigned_to='people.rmt_user'"

  include WelcomeHelper
  include ApplicationHelper

  def resp
    Person.find(:first, :conditions=>"rmt_user='#{self.assigned_to}'")
  end

  # TODO: contre-visites

  WP_shortnames = { # TODO: use the new model
  "WP1.1 - Quality Control" 		                        => "Control",
  "WP1.2 - Quality Assurance" 		                      => "Assurance",
  "WP1.3 - BAT"                                         => "BAT",
  "WP1.4 - Agility"                                     => "Agility", #NEW
  "WP1.5 - SQR"                                         => "SQR", #NEW
  "WP1.6.1 - QWR DWQAP"                                 => "DWQAP", #NEW
  "WP1.6.2 - QWR Project Setting-up"                    => "Proj. Setting-up", # NEW
  "WP1.6.3 - QWR Support, Reporting & KP"               => "Supp. Setting-up", #NEW
  "WP1.6.4 - QWR Quality Status"                        => "QS", #NEW
  "WP1.6.5 - QWR Spiders"                               => "Spiders", #NEW
  "WP1.6.6 - QWR QG BRD"                                => "QG BRD", #NEW
  "WP1.6.7 - QWR QG TD"                                 => "QG TD", #NEW
  "WP1.6.8 - QWR Lessons Learnt"                        => "QG Lessons", #NEW
  "WP2 - Quality for Maintenance" 	                    => "Maint.",
  "WP3.0 - Old Modeling"                                => "Modeling 0",
  "WP3.1 - Modeling Support"                            => "Modeling 1",
  "WP3.2 - Modeling Conception and Production"          => "Modeling 2",
  "WP3.2.1 - Business Process Layout"                   => "Biz Proc. Layout", #NEW
  "WP3.2.2 - Functional Layout (Use Cases)"             => "Func. Layout", #NEW
  "WP3.2.3 - Information Layout (Data Model)"           => "Info. Layout", #NEW
  "WP3.3 - Modeling BAT specific Control"               => "Modeling 3",
  "WP3.4 - Modeling BAT specific Production"            => "Modeling 4",
  "WP4 - Surveillance" 				                          => "Audit",
  "WP4.1 - Surveillance Audit" 		                      => "Audit",
  "WP4.2 - Surveillance Root cause"                     => "RCA",
  "WP4.3 - Actions Implementation & Control"            => "Act. Impl. Ctrl.", #NEW
  "WP5 - Change Accompaniment" 		                      => "Change",
  "WP5.1 - Change: Diagnosis & Action Plan"             => "Change Diag.", #NEW
  "WP5.2 - Change : Implementation Support & Follow-up" => "Change Impl. Supp.", #NEW
  "WP6.1 - Coaching PP" 			                          => "PP",
  "WP6.2 - Coaching BRD" 			                          => "BRD",
  "WP6.3 - Coaching V&V"                                => "V&V",
  "WP6.4 - Coaching ConfMgt"                            => "ConfMgt",
  "WP6.5 - Coaching Maintenance"                        => "C. Maint.",
  "WP6.6 - Coaching HLR"                                => "C. HLR", #NEW
  "WP6.7 - Coaching Business Process"                   => "C. Biz Proc.", #NEW
  "WP6.8 - Coaching Use Case"                           => "C. Use Case", #NEW
  "WP6.9 - Coaching Data Model"                         => "C. Data Model", #NEW
  "WP6.10.1 - Coaching Agility: Diagnosis & project launch" => "CA. Diag.", #NEW
  "WP6.10.2 - Coaching Agility: Sprint 0 support"           => "CA. Support", #NEW
  "WP6.10.3 - Coaching Agility: Sprint coaching"            => "CA. Coaching", #NEW
  "WP7.1.1 - Expertise Activities for Multi Projects: Requirements Management"            => "Multi Proj. Req.", #NEW
  "WP7.1.2 - Expertise Activities for Multi Projects: Risks Management"                   => "Multi Proj. Risks", #NEW
  "WP7.1.3 - Expertise Activities for Multi Projects: Test Management"                    => "Multi Proj. Test", #NEW
  "WP7.1.4 - Expertise Activities for Multi Projects: Change Management"                  => "Multi Proj. Change ", #NEW
  "WP7.1.5 - Expertise Activities for Multi Projects: Lessons Learnt"                     => "Multi Proj. Lessons", #NEW
  "WP7.1.6 - Expertise Activities for Multi Projects: Configuration Management"           => "Multi Proj. Conf.", #NEW
  "WP7.2.1 - Expertise Activities for Project: Requirements Management"                   => "Proj. Req.", #NEW
  "WP7.2.2 - Expertise Activities for Project: Risks Management"                          => "Proj. Risks", #NEW
  "WP7.2.3 - Expertise Activities for Project: Test Management"                           => "Proj. Test", #NEW
  "WP7.2.4 - Expertise Activities for Project: Change Management"                         => "Proj. Change", #NEW
  "WP7.2.5 - Expertise Activities for Project: Lessons Learnt"                            => "Proj. Lessons", #NEW
  "WP7.2.6 - Expertise Activities for Project: Configuration Management"                  => "Proj. Conf.", #NEW
  }


  Wp_index = { # TODO: use the new model
  "WP1.1 - Quality Control" 		    => 0,
  "WP1.2 - Quality Assurance" 		  => 4,
  "WP1.3 - Quality Control + BAT"   => 0,
  "WP1.4 - Quality Assurance + BAT" => 4,
  "WP2 - Quality for Maintenance" 	=> 8,
  "WP3.0 - Old Modeling"            => 9,
  "WP3.1 - Modeling Support"        => 9,
  "WP3.2 - Modeling Conception and Production" => 9,
  "WP3.3 - Modeling BAT specific Control"      => 9,
  "WP3.4 - Modeling BAT specific Production"   => 9,
  "WP4 - Surveillance" 				      => 10,
  "WP4.1 - Surveillance Audit" 		  => 10,
  "WP4.2 - Surveillance Root cause" => 10,
  "WP5 - Change Accompaniment" 		  => 11,
  "WP6.1 - Coaching PP" 			      => 12,
  "WP6.2 - Coaching BRD" 			      => 13,
  "WP6.3 - Coaching V&V"            => 14,
  "WP6.4 - Coaching ConfMgt"        => 15,
  "WP6.5 - Coaching Maintenance"    => 16,
  "WP1.1 - Quality ControlCV"       => 17,
  "WP1.2 - Quality AssuranceCV"     => 21
  }

  # with BAT
  Wp_index_RFP2012 = { # TODO: use the new model
  "WP1.1 - Quality Control"         => 0,
  "WP1.2 - Quality Assurance"       => 4,
  "WP1.3 - BAT"                     => 8,
  "WP2 - Quality for Maintenance"   => 12,
  "WP3.0 - Old Modeling"            => 13,
  "WP3.1 - Modeling Support"        => 14,
  "WP3.2 - Modeling Conception and Production" => 15,
  "WP3.3 - Modeling BAT specific Control"      => 16,
  "WP3.4 - Modeling BAT specific Production"   => 17,
  "WP4 - Surveillance"              => 18,
  "WP4.1 - Surveillance Audit"      => 18,
  "WP4.2 - Surveillance Root cause" => 18,
  "WP5 - Change Accompaniment"      => 19,
  "WP6.1 - Coaching PP"             => 20,
  "WP6.2 - Coaching BRD"            => 21,
  "WP6.3 - Coaching V&V"            => 22,
  "WP6.4 - Coaching ConfMgt"        => 23,
  "WP6.5 - Coaching Maintenance"    => 24,
  "WP1.1 - Quality ControlCV"       => 25,
  "WP1.2 - Quality AssuranceCV"     => 29
  }
  
  Wp_index_RFP2013 = {
    "WP1.1 - Quality Control" 		                        => 0,
    "WP1.2 - Quality Assurance" 		                      => 8,
    "WP1.3 - BAT"                                         => 16,
    "WP1.4 - Agility"                                     => 19,
    "WP1.5 - SQR"                                         => 22,
    "WP1.6.1 - QWR DWQAP"                                 => 26,
    "WP1.6.2 - QWR Project Setting-up"                    => 27,
    "WP1.6.3 - QWR Support, Reporting & KP"               => 28,
    "WP1.6.4 - QWR Quality Status"                        => 29,
    "WP1.6.5 - QWR Spiders"                               => 30,
    "WP1.6.6 - QWR QG BRD"                                => 31,
    "WP1.6.7 - QWR QG TD"                                 => 32,
    "WP1.6.8 - QWR Lessons Learnt"                        => 33,
    "WP2 - Quality for Maintenance" 	                    => 34,
    "WP3.0 - Old Modeling"                                => 35,
    "WP3.1 - Modeling Support"                            => 36,
    "WP3.2 - Modeling Conception and Production"          => 37,
    "WP3.2.1 - Business Process Layout"                   => 38,
    "WP3.2.2 - Functional Layout (Use Cases)"             => 39,
    "WP3.2.3 - Information Layout (Data Model)"           => 40,
    "WP3.3 - Modeling BAT specific Control"               => 41,
    "WP3.4 - Modeling BAT specific Production"            => 42,
    "WP4 - Surveillance" 				                          => 43,
    "WP4.1 - Surveillance Audit" 		                      => 44,
    "WP4.2 - Surveillance Root cause"                     => 45,
    "WP4.3 - Actions Implementation & Control"            => 46,
    "WP5 - Change Accompaniment" 		                      => 47,
    "WP5.1 - Change: Diagnosis & Action Plan"             => 48,
    "WP5.2 - Change : Implementation Support & Follow-up" => 49,
    "WP6.1 - Coaching PP" 			                          => 50,
    "WP6.2 - Coaching BRD" 			                          => 51,
    "WP6.3 - Coaching V&V"                                => 52,
    "WP6.4 - Coaching ConfMgt"                            => 53,
    "WP6.5 - Coaching Maintenance"                        => 54,
    "WP6.6 - Coaching HLR"                                => 55,
    "WP6.7 - Coaching Business Process"                   => 56,
    "WP6.8 - Coaching Use Case"                           => 57,
    "WP6.9 - Coaching Data Model"                         => 58,
    "WP6.10.1 - Coaching Agility: Diagnosis & project launch"=> 59,
    "WP6.10.2 - Coaching Agility: Sprint 0 support"       => 60,
    "WP6.10.3 - Coaching Agility: Sprint coaching"        => 61,
    "WP7.1.1 - Expertise Activities for Multi Projects: Requirements Management"            => 62,
    "WP7.1.2 - Expertise Activities for Multi Projects: Risks Management"                   => 63,
    "WP7.1.3 - Expertise Activities for Multi Projects: Test Management"                    => 64,
    "WP7.1.4 - Expertise Activities for Multi Projects: Change Management"                  => 65,
    "WP7.1.5 - Expertise Activities for Multi Projects: Lessons Learnt"                     => 66,
    "WP7.1.6 - Expertise Activities for Multi Projects: Configuration Management"           => 67,
    "WP7.2.1 - Expertise Activities for Project: Requirements Management"                   => 68,
    "WP7.2.2 - Expertise Activities for Project: Risks Management"                          => 69,
    "WP7.2.3 - Expertise Activities for Project: Test Management"                           => 70,
    "WP7.2.4 - Expertise Activities for Project: Change Management"                         => 71,
    "WP7.2.5 - Expertise Activities for Project: Lessons Learnt"                            => 72,
    "WP7.2.6 - Expertise Activities for Project: Configuration Management"                  => 73,
    "WP1.1 - Quality ControlCV"                           => 4,
    "WP1.2 - Quality AssuranceCV"                         => 12
  }

  Comp_index = {
  "Easy" 		  => 0,
  "Medium" 		=> 1,
  "Difficult" => 2,
  "TBD"       => 0
  }
  
  Milestone_index = {
  "M1-M3" 		=> 0,
  "M3-M5" 		=> 1,
  "M5-M10" 		=> 2,
  "Post-M10" 	=> 3,
  "N/A" 		  => 0
  }

  # reminder: minus 10% for operational meetings
  LoadsRFP2013 = [
    # WP 1.1
    [2.205,	2.328,	2.818], #0
    [3.678,	4.290,	6.005],
    [2.818,	3.798,	6.370],
    [4.410,	5.145,	7.595],
    # WP 1.1 contre visite
    [0.490,	0.490,	0.735], #4
    [0.980,	0.980,	1.470],
    [0.368,	0.368,	0.490],
    [1.960,	2.450,	2.940],
    # WP 1.2 Quality assurance
    [3.308,	3.798,	4.410], #8
    [6.253,	7.970,	10.668],
    [6.005,	6.618,	7.720],
    [5.880,	7.595,	10.045],
    # WP 1.2 Contre visite
    [0.490,	0.490,	0.490], #12
    [1.960,	2.450,	2.940],
    [1.960,	2.940,	3.920],
    [2.940,	3.920,	4.900],
    # WP 1.3
    [2.500,	3.500,	4.500], #16
    [0.750,	1.000,	1.500],
    [2.000,	2.750,	4.250],
    # WP 1.4
    [6.253,	7.970,	10.668], #19
    [1.375,	2.250,	3.125],
    [2.000,	3.000,	4.000],
    # WP 1.5
    [	0, 0,	5.000], #22  # WARNING N/A
    [	0, 3.000,	6.000],
    [	0, 3.000,	8.000],
    [	0, 0,	9.000],
    # WP 1.6.1
    [1.500,	3.000,	5.000], #26
    # WP 1.6.2
    [1.750,	2.500,	3.500], #27
    # WP 1.6.3
    [6.750,	9.000,	12.000], #28
    # WP 1.6.4
    [3.750,	18.750,	37.500], #29
    # WP 1.6.5
    [3.750,	15.000,	30.000], #30
    # WP 1.6.6
    [1.000,	1.500,	2.00], #31
    # WP 1.6.7
    [1.000,	1.500,	2.00], #32
    # WP 1.6.8
    [1.125,	1.375,	1.625], #33
    # WP 2
    [5.635,	8.453,	12.985], #34
    # WP 3.0 Old (NOTE : Should not be used  WP3.0 OLD = WP3.1)
    [9.310,	17.640,	24.990], #35
    # WP 3.1
    [9.310,	17.640,	24.990], #36
    # WP 3.2 (Values from previous RFP)
    [18.5, 42.75, 58.75], #37
    # WP 3.2.1
    [7.875,	23.875,	30.875], #38
    # WP 3.2.2
    [8.625,	15.875,	21.625], #39
    # WP 3.2.3
    [7.750,	14.500,	21.000], #40
    # WP 3.3
    [4.000,	7.000,	11.000], #41
    # WP 3.4
    [8.500,	15.500,	21.500], #42
    # WP 4 (Values from previous RFP)
    [5.125, 7.25, 11.375], #43
    # WP 4.1
    [15.000,	20.000,	30.000], #44
    # WP 4.2
    [10.000,	15.000,	25.000], #45
    # WP 4.3
    [5.000,	10.000,	20.000], #46
    # WP 5  (Values from previous RFP)
    [10, 21.75, 40], #47
    # WP 5.1
    [5.819,	12.618,	23.153], #48
    # WP 5.2
    [5.819,	12.618,	23.153], #49
    # WP 6.1
    [5.145,	12.250,	22.540], #50
    # WP 6.2
    [3.675,	11.270,	23.520], #51
    # WP 6.3
    [2.205,	6.370,	15.680], #52
    # WP 6.4
    [2.940,	14.700,	34.300], #53
    # WP 6.5
    [8.575,	12.985,	17.885], #54
    # WP 6.6
    [2.000,	5.750, 0], #55 # WARNING
    # WP 6.7
    [1.750,	7.250,	0], #56 # WARNING
    # WP 6.8
    [1.750,	7.250,	0], #57 # WARNING
    # WP 6.9
    [2.000,	8.000, 0], #58 #WARNING
    # WP 6.10.1
    [3.937,	5.905,	5.905], #59
    # WP 6.10.2
    [7.874,	11.810,	19.684], #60
    # WP 6.10.3
    [3.937,	7.874,	15.747], #61
    # WP 7.1.1
    [5.500,	10.000,	15.000], #62
    # WP 7.1.2
    [3.500,	8.000, 13.000], #63
    # WP 7.1.3
    [4.500,	8.000, 13.000], #64
    # WP 7.1.4
    [3.500, 0, 0], #65 # WARNING
    # WP 7.1.5
    [3.500,	8.000, 13.000], #66
    # WP 7.1.6
    [3.500,	8.000, 13.000], #67
    # WP 7.2.1
    [4.500,	6.000,	9.000], #68
    # WP 7.2.2
    [1.750, 0, 0], #69 # WARNING
    # WP 7.2.3
    [3.250,	4.000,	7.000], #70
    # WP 7.2.4
    [1.750,	6.000,	9.000], #71
    # WP 7.2.5
    [1.750,	0, 0], #72 # WARNING
    # WP 7.2.6
    [1.750,	4.000,	7.000] #73
  ]
    
  LoadsRFP2012 = [
    # WP 1.1
    [1.875, 2, 2.375],
    [3.125, 3.75, 5.25],
    [2.375, 3.25, 5.5],
    [3.75, 4.5, 6.5],
    # WP 1.2
    [2.875, 3.25, 3.75],
    [5.375, 6.875, 9.25],
    [5.25, 5.75, 6.625],
    [5.125, 6.5, 8.625],

    # BAT minus 10% total is [4.75, 6.5, 9.25]
    # WP 1.3 (BAT)
    [0, 0, 0], # no M1-M3
    [2.125, 3, 3.875],
    [0.625, 0.875, 1.25],
    [1.75, 2.375, 3.625],

    # WP 2
    [4.875, 7.25, 11.25],

    # WP 3.0 Old
    [8.5, 16.25, 22.5],
    # WP 3.1
    [8.5, 16.25, 22.5],
    # WP 3.2
    [18.5, 42.75, 58.75],
    # WP 3.3
    [3.625, 6.25, 10],
    # WP 3.4
    [7.625, 14, 19.375],
    # WP 4
    [5.125, 7.25, 11.375],
    # WP 5
    [10, 21.75, 40],
    # WP 6
    [4.5, 10.625, 19.5],
    [3.125, 9.75, 20.375],
    [1.875, 5.5, 13.5],
    [2.5, 12.75, 29.625],
    [7.375, 11.25, 15.5],
    # WP 1.1 CV
    [0.375, 0.375, 0.625],
    [0.875, 0.875, 1.25],
    [0.375, 0.375, 0.375],
    [1.75, 2.125, 2.5],
    # WP 1.2 CV
    [0.375, 0.375, 0.375],
    [1.75, 2.125, 2.5],
    [1.75, 2.5, 3.375],
    [2.5, 3.375, 4.25]
    ]
      
  LoadsRFP2012_OLD = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.375, 4, 5.5],
    [2.625, 3.5, 5.875],
    [4.0, 4.75, 7.0],
    # WP 1.2
    [3.0, 3.5, 4.0],
    [5.75, 7.375, 9.75],
    [5.5, 6.125, 7.125],
    [5.375, 7.0, 9.25],

    # BAT minus 10% total is [4.75, 6.5, 9.25]
    # WP 1.3 (BAT)
    [0, 0, 0], # no M1-M3
    [2.25, 3.25, 4],
    [0.625, 0.875, 1.375],
    [1.75, 2.5, 3.875],

    # WP 2
    [5.125, 7.75, 11.875],

    # WP 3.0 Old
    [8.5, 16.25, 22.5],
    # WP 3.1
    [8.5, 16.25, 22.5],
    # WP 3.2
    [18.5, 42.75, 58.75],
    # WP 3.3
    [3.625, 6.25, 10],
    # WP 3.4
    [7.625, 14, 19.375],
    # WP 4
    [5.5, 7.625, 12.125],
    # WP 5
    [10.75, 23.125, 42.5],
    # WP 6
    [4.75, 11.25, 20.75],
    [3.375, 10.375, 21.625],
    [2.0, 5.875, 14.375],
    [2.75, 13.5, 31.5],
    [7.875, 11.875, 16.375],
    # WP 1.1 CV
    [0.5, 0.5, 0.625],
    [0.875, 0.875, 1.375],
    [0.375, 0.375, 0.5],
    [1.75, 2.25, 2.75],
    # WP 1.2 CV
    [0.5, 0.5, 0.5],
    [1.75, 2.25, 2.75],
    [1.75, 2.75, 3.625],
    [2.75, 3.625, 4.5]
    ]


  Loads2011 = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.25, 3.875, 5.375],
    [2.625, 3.5, 5.875],
    [4.0, 4.75, 7.0],
    # WP 1.2
    [3.0, 3.5, 4.0],
    [5.5, 7.0, 9.375],
    [5.375, 6.0, 7.0],
    [5.375, 7.0, 9.25],
    # WP 2
    [5.125, 7.75, 11.875],
    # WP 3
    [8.5, 16.25, 22.5],
    # WP 4
    [5.5, 7.625, 12.125],
    # WP 5
    [10.75, 23.125, 42.5],
    # WP 6
    [4.75, 11.25, 20.75],
    [3.375, 10.375, 21.625],
    [2.0, 5.875, 14.375],
    [2.75, 13.5, 31.5],
    [7.875, 11.875, 16.375],
    # WP 1.1 CV
    [0.5, 0.5, 0.625],
    [0.875, 0.875, 1.375],
    [0.375, 0.375, 0.5],
    [1.75, 2.25, 2.75],
    # WP 1.2 CV
    [0.5, 0.5, 0.5],
    [1.75, 2.25, 2.75],
    [1.75, 2.75, 3.625],
    [2.75, 3.625, 4.5]
    ]


  Loads2010 = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.625,4.25,6],
    [2.875,3.875,6.5],
    [4.5,5.25,7.75],
    # WP 1.2
    [3.375,3.875,4.5],
    [6.125,7.75,10.375],
    [6,6.625,7.75],
    [6,7.75,10.25],
    # WP 2
    [5.75,8.625,13.25],
    # WP 3
    [9.5,18,25],
    # WP 4
    [6.125,8.5,13.5],
    # WP 5
    [11.875,25.75,47.25],
    # WP 6
    [5.25,12.5,23],
    [3.75,11.5,24],
    [2.25,6.5,16],
    [3,15,35],
    [8.75,13.25,18.25],
    # WP 1.1 CV
    [0.5,0.5,0.75],
    [1,1,1.5],
    [0.375,0.375,0.5],
    [2,2.5,3],
    # WP 1.2 CV
    [0.5,0.5,0.5],
    [2,2.5,3],
    [2,3,4],
    [3,4,5]]

  RMT_TO_BAM = {
    'M1-M3'=>   ['M3','G2','pg2','g2','sM3'],
    'M3-M5'=>   ['M5', 'M5/M7','G5','pg5','g5','sM5'],
    'M5-M10'=>  ['M9/M10', 'M10','G6','pg6','g6'],
    'Post-M10'=>['M12/M13', 'M13', 'sM13','G9','pg9','g9'],
     }

  PHASE_MILESTONES = {
    'M1-M3'=>   ['M3','G2','pg2','g2','sM3'],
    'M3-M5'=>   ['QG BRD', 'QG ARD', 'M5', 'M5/M7','G3','pg3','g3','G4','pg4','g4','G5','pg5','g5','sM5'],
    'M5-M10'=>  ['M7', 'M9', 'M9/M10', 'M10','G6','pg6','g6'],
    'Post-M10'=>['QG TD', 'M10a', 'M11', 'QG MIP', 'M12', 'M12/M13', 'M13', 'M14','sM13','sM14','G7','pg7','g7','G8','pg8','g8','G9','pg9','g9'],
    'WP2 - Quality for Maintenance' 	=> ['CCB', 'QG TD M', 'MIPM'],
    'WP6.1 - Coaching PP' =>    ['M3', 'G2'],
    'WP6.2 - Coaching BRD' =>   ['M5', 'M5/M7', 'G5'],
    'WP6.3 - Coaching V&V' =>   ['M11', 'G7'],
    'WP6.4 - Coaching ConfMgt' =>     ['M3', 'G2'],
    'WP6.5 - Coaching Maintenance' => ['M13','CCB','MIPM'],
    'WP3.0 - Old Modeling' =>         ['M5', 'M5/M7', 'G5'],
    'WP3.1 - Modeling Support' =>     ['M5', 'M5/M7', 'G5'],
    'WP3.2 - Modeling Conception and Production' => ['M5', 'M5/M7', 'G5'],
    'WP3.3 - Modeling BAT specific Control' =>      ['M5', 'M5/M7', 'G5'],
    'WP3.4 - Modeling BAT specific Production' =>   ['M5', 'M5/M7', 'G5'],
    'WP5 - Change Accompaniment' 		  => ['M11'],
    'WP1.6.2 - QWR Project Setting-up' 		  => ['M3','G2','pg2','g2'],
    'WP1.6.6 - QWR QG BRD' 		  => ['QG BRD'],
    'WP1.6.7 - QWR QG TD' 		  => ['QG TD'],
    'WP1.6.8 - QWR Lessons Learnt' 		  => ['M5','M5/M7','G5','pg5','g5','M10','M14','G9','pg9','g9'],
    'WP3.2.1 - Modeling Business Process Layout' => ['M5', 'M5/M7', 'G5'],
    'WP3.2.2 - Functional Layout (Use Cases)' => ['M5', 'M5/M7', 'G5'],
    'WP3.2.3 - Information Layout (Data Model)' => ['M5', 'M5/M7', 'G5'],
    'WP5.1 - Change: Diagnosis & Action Plan' 		  => ['M11'],
    'WP5.2 - Change : Implementation Support & Follow-up' 		  => ['M11'],
    'WP6.6 - Coaching HLR' =>     ['M3', 'G2', 'pg2', 'g2', 'sM3'],
    'WP6.7 - Coaching Business Process' =>     ['M5', 'M5/M7', 'G5', 'pg5', 'g5'],
    'WP6.8 - Coaching Use Case' =>     ['M5', 'M5/M7', 'G5', 'pg5', 'g5'],
    'WP6.9 - Coaching Data Model' =>     ['M5', 'M5/M7', 'G5', 'pg5', 'g5'],
    'WP6.10.1 - Coaching Agility - Diagnosis & Project Launch' =>     ['M5', 'M5/M7', 'G5', 'pg5', 'g5'],
    'WP6.10.2 - Coaching Agility - Sprint 0' =>     ['M5', 'M5/M7', 'G5', 'pg5', 'g5'],
    'WP6.10.3 - Coaching Agility - Sprint n' =>     ['M7', 'M9', 'M9/M10', 'M10','G6','pg6','g6'],
    'WP7.2.1 - Expertise Activities for Project: Requirements Management' => ['M11', 'G7', 'pg7', 'g7'],
    'WP7.2.2 - Expertise Activities for Project: Risks Management' => ['M13', 'G8', 'pg8', 'g8'],
    'WP7.2.3 - Expertise Activities for Project: Test Management' => ['M11', 'G7', 'pg7', 'g7'],
    'WP7.2.4 - Expertise Activities for Project: Change Management' => ['M11', 'G7', 'pg7', 'g7'],
    'WP7.2.5 - Expertise Activities for Project: Lessons Learnt' => ['M14', 'G9', 'pg7', 'g7'],
    'WP7.2.6 - Expertise Activities for Project: Configuration Management' => ['M3', 'G2', 'pg2', 'g2']
    }

  def wp_index(wp, cv)
    rv = Wp_index[wp+(cv=="Yes" ? "CV":"")]
    raise "no workpackage #{wp}" if not rv
    rv
  end

  def wp_index_RFP2012(wp, cv)
    rv = Wp_index_RFP2012[wp+(cv=="Yes" ? "CV":"")]
    raise "no workpackage #{wp}" if not rv
    rv
  end

  def wp_index_RFP2013(wp, cv)
    rv = Wp_index_RFP2013[wp+(cv=="Yes" ? "CV":"")]
    raise "no workpackage #{wp}" if not rv
    rv
  end
  
  def milestone_index(m)
    rv = Milestone_index[m]
    raise "no milestone #{m}" if not rv
    rv
  end

  def date
    return Date.parse(self.actual_m_date) if self.actual_m_date and self.actual_m_date!=""
    return Date.parse(self.milestone_date) if self.milestone_date and self.milestone_date!=""
    nil
  end

  def name # so it is the same as Milestone#name
    self.milestone
  end

  def comp_index(c)
    rv = Comp_index[c]
    raise "no complexity #{c}" if not rv
    rv
  end

  def workload
    return 0  if self.status == "cancelled" or self.status=="removed" or self.status == "feedback" or self.status == "performed" or self.resolution == "ended"
    workload2
  end

  def workload2
    if self.sdpiteration == "2013-Y3"
      return LoadsRFP2013[wp_index_RFP2013(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    elsif self.sdpiteration == "2013" or  self.sdpiteration == "2012" or Date.parse(self.date_submitted) >= Date.parse('2012-01-10') or (self.status_new and self.status_new >= Date.parse('2012-01-10'))
      return LoadsRFP2012[wp_index_RFP2012(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    elsif self.sdpiteration == "2011" or self.sdpiteration == "2011-Y2"
      return Loads2011[wp_index(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    elsif self.sdpiteration == "2010"
      return Loads2010[wp_index(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    else
      0
    end
  end

  # calculate a start date based on the milestone date
  def gantt_start_date
    if self.start_date == ''
      if self.milestone_date != ''
        return (Time.parse(self.milestone_date) - real_duration.days).strftime("%Y-%m-%d")
      else
        return Date.new.strftime("%Y-%m-%d")
      end
    else
      return self.start_date
    end
  end

  # taking into account the start date and the milestone date
  def real_duration
    faed = foreseen_end_date_arr
    rv = if faed != nil and self.start_date != ''
      days = (Time.parse(faed[0]) - Time.parse(self.start_date)) / 1.days
      minus_week_ends(days)
    else
      gantt_duration
    end
    rv = 1 if rv < 1
    rv
  end

  def minus_week_ends(days)
   (days - ((days/7).to_i)*2).to_i
  end

  def rload
    real = real_duration
    real = 1 if real == 0
    return ((gantt_duration.to_f / real) * 100).to_i
  end

  def gantt_duration
    (self.workload+0.5).to_i
  end

  def foreseen_actual_end_date_arr
    return [self.end_date, "e"] if self.end_date and self.end_date != ''
    return [self.actual_m_date, "a"] if self.actual_m_date and self.actual_m_date != ''
    return nil
  end

  def foreseen_end_date_arr
    faed = foreseen_actual_end_date_arr
    return faed if faed != nil
    return [self.milestone_date, "m"] if self.milestone_date and self.milestone_date != ''
    return nil
  end

  def foreseen_end_date_str
    arr = foreseen_end_date_arr
    return "" if arr == nil
    return arr[0] + " (#{arr[1]})"
  end

  def my_end_date
    f = foreseen_end_date_arr
    return f[0] if f
    return (Date.parse(gantt_start_date) + real_duration).to_s
  end

  def sanitized_status
    sanitize(self.status)
  end

  def sanitized_resolution
    sanitize(self.resolution)
  end

  def workpackage_name
    get_workpackage_name_from_summary(self.summary, self.project_name)
  end

  def brn
    self.summary.split(/\[([^\]]*)\]/)[5]
  end

  def move_to_project(p)
    self.project_id = p.id
    self.save
  end

  def progress_status
    return case self.resolution
      when 'not started'; 4
      when 'planned';     3
      when 'in progress'; 2
      when 'ended';       1
      else;               0
    end
  end

  # options is a hash
  # :trigram is the trigram of the person on which to filter
  #  ex: sdp_tasks({:trigram=>'MFM'})
  def sdp_tasks(options=nil)
    cond = ''
    if options
      cond += " and collab LIKE '%#{options[:trigram]}%'" if options[:trigram] and options[:trigram] != ''
    end
    SDPTask.find(:all, :conditions=>"request_id='#{self.request_id}' #{cond}")
  end

  def sdp_tasks_initial_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.initial}
  end

  def sdp_tasks_remaining_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.remaining}
  end

  def sdp_tasks_balancei_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.balancei}
  end

  def sdp_phase_id
    SdpDB.sdp_phase_id(self.work_package)
  end

  def sdp_proposal_id
    SdpDB.sdp_proposal_id(self.work_package)
  end

  def sdp_domain_id
    SdpDB.sdp_domain_id(self.workstream)
  end

  def sdp_activity_id
    m = (self.milestone=="N/A") ? "All" : self.milestone
    SdpDB.sdp_activity_id([m,self.work_package])
  end

  def sdp_user_id
    p = Person.find_by_rmt_user(self.assigned_to)
    return -1 if not p
    return p.sdp_id
  end

  def shortname
    WP_shortnames[self.work_package]
  end

  def workload_name
    ##{appended_string(project.workstream, 6, "&nbsp;")}
   "<b>#{self.project ? self.project.full_name : "no project"}</b> <u>#{self.shortname}</u> #{self.milestone} (<a title='RMT' href='http://toulouse.sqli.com/EMN/view.php?id=#{self.request_id.to_i}'>##{self.request_id.to_i}</a>)"
  end

  # return the corresponding milestone names for this request
  def milestone_names
    if self.milestone != 'N/A'
      PHASE_MILESTONES[self.milestone]
    else
      PHASE_MILESTONES[self.work_package]
    end
  end

  # return the corresponding project milestones for this request
  def milestones
    names = self.milestone_names
    return [] if !names
    self.project.milestones.select{|m| names.include?(m.name)}
  end

  def deploy_checklists
    for t in ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0")
      deploy_checklist(t)
    end
  end

  def deploy_checklist(ctemplate)
    self.milestones.select{ |m1| m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0 and ctemplate.milestone_names.map{|mn| mn.title}.include?(m1.name)}.each { |m|
      m.deploy_checklist(ctemplate, self)
      }
  end

  def wl_load_by_year(year)
    # get workload line
    line = WlLine.find_by_request_id(self.request_id)
    return nil if !line
    line.wl_loads.select{|l| l.week.to_s[0..3]==year.to_s}.inject(0) { |sum, load| sum+=load.wlload}
  end

  def bam_milestone
    return nil if self.milestone=='N/A'
    RMT_TO_BAM[self.milestone].each { |m_name|
      m = self.project.find_milestone_by_name(m_name) if self.project
      return m if m
      }
    return nil
  end

  def background_for_po
    if self.po.strip=="2012"
      if self.date
        return " style='background: #FAA'"
      else
        return " style='background: #FFA'"
      end
    else
      return ""
    end    
  end
  
  # Manage count value for Counters tickets
  def update_ticket_counters
    # Get the counter_log of this request
    counterLogObj = self.counter_log
		
    # Get the new value for this request
    newCounterValue = 0
    counterBase = CounterBaseValue.first(
		:conditions => ["complexity = ? and sdp_iteration = ? and workpackage = ?",self.complexity,self.sdpiteration,self.work_package])
		if counterBase
		  newCounterValue = counterBase.value
    end
    
		# Create new counter_log 
		if (!counterLogObj) 
	    counterLogObj = CounterLog.new
	    counterLogObj.request_id     = self.id
	    counterLogObj.import_date    = DateTime.current
	    counterLogObj.counter_value  = newCounterValue
	    counterLogObj.validity       = 1
	  # Update counter_log
		elsif(counterLogObj.counter_value != newCounterValue)
			  counterLogObj.counter_value = newCounterValue
		end
		
		if self.status == "To be validated"
		  counterLogObj.validity = false
		else
		  counterLogObj.validity = true
		end
		counterLogObj.save
		# TODO : Manage the validity !!!!!
  end

private

  def sanitize(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end

end
