require 'spreadsheet'
class LessonCollectsController < ApplicationController
  layout 'tools'

  # LESSON SHEET ROWS INDEX
  LESSON_BEGIN_HEADER               = 0
  LESSON_END_HEADER                 = 8
  LESSON_BEGIN_CONTENT              = 10
  
  # LESSON SHEET HEADER INDEX
  PM_HEADER                         = "PM :"
  QWR_HEADER                        = "QWR/SQR :"
  COC_HEADER                        = "CoC :"
  SUITE_HEADER                      = "Suite Name"
  PROJECT_HEADER                    = "Project Name :"
  
  # LESSON SHEET CELLS INDEX
  LESSON_CELL_ID                    = 1 
  LESSON_CELL_MILESTONE             = 2
  LESSON_CELL_LESSON_LEARNT         = 3
  LESSON_CELL_TOPICS                = 4
  LESSON_CELL_PB_CAUSE              = 5
  LESSON_CELL_IMPROVEMENT           = 6
  LESSON_CELL_AXES                  = 7
  LESSON_CELL_SUB_AXES              = 8
  
  # LESSON SHEET CELLS LABEL
  LESSON_CELL_ID_LABEL              = "id"           
  LESSON_CELL_MILESTONE_LABEL       = "milestone"  
  LESSON_CELL_LESSON_LEARNT_LABEL   = "lesson_learnt"
  LESSON_CELL_TOPICS_LABEL          = "topics"     
  LESSON_CELL_PB_CAUSE_LABEL        = "pb_causes" 
  LESSON_CELL_IMPROVEMENT_LABEL     = "improvement" 
  LESSON_CELL_AXES_LABEL            = "axes"      
  LESSON_CELL_SUB_AXES_LABEL        = "sub_axes"

  # ACTION SHEET ROWS INDEX 
  ACTION_BEGIN_CONTENT              = 3

  # ACTION SHEET CELLS INDEX  
  ACTION_CELL_REF                   = 1
  ACTION_CELL_CREATION_DATE         = 2
  ACTION_CELL_SOURCE                = 3
  ACTION_CELL_TITLE                 = 4
  ACTION_CELL_STATUS                = 5
  ACTION_CELL_ACTIONNEE             = 6
  ACTION_CELL_DUE_DATE              = 7
  ACTION_CELL_BENEFIT               = 14
  ACTION_CELL_LEVEL_INVEST          = 15

  # ACTION SHEET CELLS LABEL
  ACTION_CELL_REF_LABEL             = "ref" 
  ACTION_CELL_CREATION_DATE_LABEL   = "creation_date"
  ACTION_CELL_SOURCE_LABEL          = "source"       
  ACTION_CELL_TITLE_LABEL           = "title"        
  ACTION_CELL_STATUS_LABEL          = "status"       
  ACTION_CELL_ACTIONNEE_LABEL       = "actionnee"
  ACTION_CELL_DUE_DATE_LABEL        = "due_date"     
  ACTION_CELL_BENEFIT_LABEL         = "benefit"
  ACTION_CELL_LEVEL_INVEST_LABEL    = "level_of_investment"

  # ASSESSMENT SHEET ROWS INDEX
  ASSESSMENT_BEGIN_CONTENT          = 3

  # ASSESSMENT SHEET CELLS INDEX
  ASSESSMENT_CELL_RMT_ID            = 0
  ASSESSMENT_CELL_MILESTONE         = 1
  ASSESSMENT_CELL_DET_PRES          = 2
  ASSESSMENT_CELL_QUAL_GATES        = 3
  ASSESSMENT_CELL_M_PREP            = 4
  ASSESSMENT_CELL_PROJ_SET_UP       = 5
  ASSESSMENT_CELL_LESSONS           = 6
  ASSESSMENT_CELL_SUPP              = 7
  ASSESSMENT_CELL_IMP               = 8
  ASSESSMENT_CELL_COMMENTS          = 9

  # ASSESSMENT SHEET CELLS LABEL
  ASSESSMENT_CELL_RMT_ID_LABEL      = "rmt_id"              
  ASSESSMENT_CELL_MILESTONE_LABEL   = "milestone"         
  ASSESSMENT_CELL_DET_PRES_LABEL    = "detailed_presentation"
  ASSESSMENT_CELL_QUAL_GATES_LABEL  = "quality_gates"       
  ASSESSMENT_CELL_M_PREP_LABEL      = "milestones_prep"     
  ASSESSMENT_CELL_PROJ_SET_UP_LABEL = "project_setting_up"  
  ASSESSMENT_CELL_LESSONS_LABEL     = "lessons_learnt"      
  ASSESSMENT_CELL_SUPP_LABEL        = "support_level"       
  ASSESSMENT_CELL_IMP_LABEL         = "improve_mt"          
  ASSESSMENT_CELL_COMMENTS_LABEL    = "comments"            

  # ------------------------------------------------------------------------------------
  # ACTIONS
  # ------------------------------------------------------------------------------------

  # Index
  def index
    # Params init
  	@lessonFiles   = nil
    @ws_array       = Array.new
    @suites_array   = Array.new
    @ws_selected    = -1
    @suite_selected = -1
    @imported       = params[:imported]

    # Params set
    if params[:ws_id] and params[:ws_id] != "-1"
      @ws_selected = params[:ws_id]
    end
    if params[:suite_id] and params[:suite_id] != "-1"
      @suite_selected = params[:suite_id]
    end

    # Workstream list 
  	ws_list   = Workstream.find(:all)
    @ws_array << ["ALL", -1]
    ws_list.each{ |ws| 
      @ws_array << [ws.name, ws.id]
    }

    # Suite tag list
    suite_list = SuiteTag.find(:all)
    @suites_array << ["ALL", -1]
    suite_list.each{ |suite|
      @suites_array << [suite.name, suite.id]
    }

    # Lesson list query conditions
    conditions = nil
    if (@ws_selected and @ws_selected != -1)
      ws_select_obj = Workstream.find(@ws_selected)
      if (ws_select_obj)
       conditions = "workstream like '%#{ws_select_obj.name}%'"
      end
    end

    if (@suite_selected and @suite_selected != -1)
      suite_select_obj = SuiteTag.find(@suite_selected)
      if (suite_select_obj)
        if (conditions)
          conditions << " AND suite_name like '%#{suite_select_obj.name}%'"
        else
          conditions = "suite_name like '%#{suite_select_obj.name}%'"
        end
      end
    end

    # Lesson list query
    if (conditions)
      @lessonFiles = LessonCollectFile.find(:all, :conditions=>conditions)
    else
      @lessonFiles = LessonCollectFile.find(:all)
    end
  end

  # Import
  def import

    # Import excel file
    doc         = load_lessons_excel_file(params[:upload])
    lessons     = doc.worksheet 'Lessons learnt Collect'
    actions     = doc.worksheet 'Actions'
    assessments = doc.worksheet 'Assessment of quality service'

    # Parse excel file
    lessons_header_hash       = parse_lessons_excel_header(lessons)
    lessons_content_array     = parse_lessons_excel_content(lessons)
    actions_content_array     = parse_actions_excel_content(actions)
    assessments_content_array = parse_assessments_content(assessments)

    # Create lesson file
    lesson_file               = LessonCollectFile.new
    lesson_file.pm            = lessons_header_hash["pm"]
    lesson_file.qwr_sqr       = lessons_header_hash["qwr"]
    lesson_file.workstream    = lessons_header_hash["coc"]
    lesson_file.suite_name    = lessons_header_hash["suite"]
    lesson_file.project_name  = lessons_header_hash["project"]
    lesson_file.save

    # Save lessons
    lessons_content_array.each do |l|
      lesson_objs = LessonCollect.find(:all,:conditions=>["lesson_id = ?", l["id"]])
      if lesson_objs == nil or lesson_objs.count == 0
        lesson_collect = LessonCollect.new
        lesson_collect.lesson_collect_file_id = lesson_file.id
        lesson_collect.lesson_id              = l[LESSON_CELL_ID_LABEL]           
        lesson_collect.milestone              = l[LESSON_CELL_MILESTONE_LABEL]    
        lesson_collect.type_lesson            = l[LESSON_CELL_LESSON_LEARNT_LABEL]
        lesson_collect.topics                 = l[LESSON_CELL_TOPICS_LABEL]       
        lesson_collect.cause                  = l[LESSON_CELL_PB_CAUSE_LABEL]    
        lesson_collect.improvement            = l[LESSON_CELL_IMPROVEMENT_LABEL]  
        lesson_collect.axes                   = l[LESSON_CELL_AXES_LABEL]         
        lesson_collect.sub_axes               = l[LESSON_CELL_SUB_AXES_LABEL]   
        lesson_collect.save
      end 
    end
    # Save Actions
    actions_content_array.each do |a|
      action_objs = LessonCollectAction.find(:all,:conditions=>["ref = ?", a["ref"]])
      if action_objs == nil or action_objs.count == 0
        lesson_collect_action = LessonCollectAction.new
        lesson_collect_action.lesson_collect_file_id  = lesson_file.id
        lesson_collect_action.ref                     = a[ACTION_CELL_REF_LABEL]          
        lesson_collect_action.creation_date           = a[ACTION_CELL_CREATION_DATE_LABEL]
        lesson_collect_action.source                  = a[ACTION_CELL_SOURCE_LABEL]       
        lesson_collect_action.title                   = a[ACTION_CELL_TITLE_LABEL]        
        lesson_collect_action.status                  = a[ACTION_CELL_STATUS_LABEL]       
        lesson_collect_action.actionne                = a[ACTION_CELL_ACTIONNEE_LABEL]       
        lesson_collect_action.due_date                = a[ACTION_CELL_DUE_DATE_LABEL]     
        lesson_collect_action.benefit                 = a[ACTION_CELL_BENEFIT_LABEL]      
        lesson_collect_action.level_of_investment     = a[ACTION_CELL_LEVEL_INVEST_LABEL]      
        lesson_collect_action.save
      end
    end
    # Save Assessemnets
    assessments_content_array.each do |a|
      assessment_objs = LessonCollectAssessment.find(:all,:conditions=>["lesson_id = ?", a["rmt_id"]])
      if assessment_objs == nil or assessment_objs.count == 0
        lesson_collect_assessment = LessonCollectAssessment.new
        lesson_collect_assessment.lesson_collect_file_id  = lesson_file.id
        lesson_collect_assessment.lesson_id               = a[ASSESSMENT_CELL_RMT_ID_LABEL]               
        lesson_collect_assessment.milestone               = a[ASSESSMENT_CELL_MILESTONE_LABEL]            
        lesson_collect_assessment.mt_detailed_desc        = a[ASSESSMENT_CELL_DET_PRES_LABEL]
        lesson_collect_assessment.quality_gates           = a[ASSESSMENT_CELL_QUAL_GATES_LABEL]        
        lesson_collect_assessment.milestones_preparation  = a[ASSESSMENT_CELL_MILESTONE_LABEL]      
        lesson_collect_assessment.project_setting_up      = a[ASSESSMENT_CELL_PROJ_SET_UP_LABEL]   
        lesson_collect_assessment.lessons_learnt          = a[ASSESSMENT_CELL_LESSONS_LABEL]       
        lesson_collect_assessment.support_level           = a[ASSESSMENT_CELL_SUPP_LABEL]        
        lesson_collect_assessment.mt_improvements         = a[ASSESSMENT_CELL_IMP_LABEL]           
        lesson_collect_assessment.comments                = a[ASSESSMENT_CELL_COMMENTS_LABEL]           
        lesson_collect_assessment.save  
      end
    end

    redirect_to(:action=>'index', :imported=>1)
  end

  # Export
  def export
    begin
      # Variables
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      lessonFiles   = nil
      @ws_selected  = params[:ws_id_hidden]
      ws_select_obj = nil 
      if @ws_selected and @ws_selected != "-1"
        ws_select_obj = Workstream.find(@ws_selected)
      end

      # Lesson files
      if (ws_select_obj)
       lessonFiles  = LessonCollectFile.find(:all, :conditions=>["workstream like ?", "%#{ws_select_obj.name}%"])
      else
       lessonFiles  = LessonCollectFile.find(:all)
      end

      # Data
      lessonCollects    = Array.new
      lessonActions     = Array.new
      lessonAssessments = Array.new
      @lessonCollectsHeader    = ["COC",
                                   "Suite Name",
                                   "Project Name",
                                   "Date of export",
                                   "PM","QWR/SQR",
                                   "ID(Don't touch)",
                                   "Milestone of Collect",
                                   "Lesson learnt / Best Practice",
                                   "TOPICS(Observations / Fact / Problems)",
                                   "Pb cause","Improvement / Best Practices",
                                   "Axes of anaylses",
                                   "Sub Axes"]

      @lessonActionsHeader     = ["COC",
                                  "Suite Name",
                                  "Project Name",
                                  "Date of export",
                                  "PM","QWR/SQR",
                                  "Ref.(Don’t touch)",
                                  "Creation Date",
                                  "Source",
                                  "Title",
                                  "Status",
                                  "Actionn",
                                  "Due Date"]

      @lessonAssessmentsHeader = ["COC",
                                  "Suite Name",
                                  "Project Name",
                                  "Date of export",
                                  "PM",
                                  "QWR/SQR",
                                  "ID RMT (LL ticket)",
                                  "Milestone session",
                                  "Did you have a detailed presentation of the provided M&T quality activities?",
                                  "Quality Gates (BRD/TD)",
                                  "Milestones preparation",
                                  "Project Setting-up",
                                  "Lessons Learnt",
                                  "Support Level",
                                  "What could have been done to improve global M&T quality services?",
                                  "Comments"]

      @exportArray = Array.new
      lessonFiles.each do |lf|
        exportHash = Hash.new
        exportHash["file"] = lf
        exportHash["lessonCollects"]          = LessonCollect.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        exportHash["lessonActions"]           = LessonCollectAction.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        exportHash["lessonCollectAssessment"] = LessonCollectAssessment.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        @exportArray << exportHash
      end

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="lessons_learnt_collect_export.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end
  end

  def delete

  end
  
  # ------------------------------------------------------------------------------------
  # IMPORT FUNCTIONS
  # ------------------------------------------------------------------------------------

  # Load excel file and return the doc
  def load_lessons_excel_file(post)
    redirect_to '/lesson_collects/index' and return if post.nil? or post['datafile'].nil?
    Spreadsheet.client_encoding = 'UTF-8'
    return Spreadsheet.open post['datafile']
  end

  # Lessons header
  # Return hash :
  #  lessons_header_hash["pm"]  
  #  lessons_header_hash["qwr"]     
  #  lessons_header_hash["coc"]     
  #  lessons_header_hash["suite"]   
  #  lessons_header_hash["project"] 
  def parse_lessons_excel_header(consoSheet)
    next_cell_is_pm      = false
    next_cell_is_qwr     = false
    next_cell_is_coc     = false
    next_cell_is_suite   = false
    next_cell_is_project = false

    pm_value      = nil
    qwr_value     = nil
    coc_value     = nil
    suite_value   = nil
    project_value = nil


    for i in LESSON_BEGIN_HEADER..LESSON_END_HEADER do
      consoSheet.row(i).each do |header_cell|
        # Save the value of cell
        if next_cell_is_pm
          pm_value = header_cell
          next_cell_is_pm = false
        elsif next_cell_is_qwr
          qwr_value = header_cell
          next_cell_is_qwr = false
        elsif next_cell_is_coc
          coc_value = header_cell
          next_cell_is_coc = false
        elsif next_cell_is_suite
          suite_value = header_cell
          next_cell_is_suite = false
        elsif next_cell_is_project
          project_value = header_cell
          next_cell_is_project = false
        end

        # Detect if the next cell contain header values
        if (header_cell.to_s == PM_HEADER)
          next_cell_is_pm = true
        elsif (header_cell.to_s == QWR_HEADER)
          next_cell_is_qwr = true
        elsif (header_cell.to_s == COC_HEADER)
          next_cell_is_coc = true
        elsif (header_cell.to_s == SUITE_HEADER)
          next_cell_is_suite = true
        elsif (header_cell.to_s == PROJECT_HEADER)
          next_cell_is_project = true
        end
        
      end
    end

    lessons_header_hash = Hash.new
    lessons_header_hash["pm"]      = pm_value
    lessons_header_hash["qwr"]     = qwr_value
    lessons_header_hash["coc"]     = coc_value
    lessons_header_hash["suite"]   = suite_value
    lessons_header_hash["project"] = project_value

    return lessons_header_hash
  end

  # Lessons content
  # Return Array of hashs
  # row_hash["id"]           
  # row_hash["milestone"]    
  # row_hash["lesson_learnt"]
  # row_hash["topics"]       
  # row_hash["pb_causes"]    
  # row_hash["improvement"]  
  # row_hash["axes"]         
  # row_hash["sub_axes"]     
  def parse_lessons_excel_content(consoSheet)
    # Var
    lessons_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= LESSON_BEGIN_CONTENT) and (conso_row[LESSON_CELL_ID]) and (conso_row[LESSON_CELL_ID].value) and (conso_row[LESSON_CELL_ID].value.length > 0))
        row_hash = Hash.new
        row_hash[LESSON_CELL_ID_LABEL]              = conso_row[LESSON_CELL_ID].value.to_s
        row_hash[LESSON_CELL_MILESTONE_LABEL]       = conso_row[LESSON_CELL_MILESTONE].to_s
        row_hash[LESSON_CELL_LESSON_LEARNT_LABEL]   = conso_row[LESSON_CELL_LESSON_LEARNT].to_s
        row_hash[LESSON_CELL_TOPICS_LABEL]          = conso_row[LESSON_CELL_TOPICS].to_s
        row_hash[LESSON_CELL_PB_CAUSE_LABEL]        = conso_row[LESSON_CELL_PB_CAUSE].to_s
        row_hash[LESSON_CELL_IMPROVEMENT_LABEL]     = conso_row[LESSON_CELL_IMPROVEMENT].to_s
        row_hash[LESSON_CELL_AXES_LABEL]            = conso_row[LESSON_CELL_AXES].to_s
        row_hash[LESSON_CELL_SUB_AXES_LABEL]        = conso_row[LESSON_CELL_SUB_AXES].to_s
        lessons_content_array << row_hash
      end
      i += 1
    end
    return lessons_content_array
  end

  # Actions content
  # Return Array of Hashs
  # row_hash["ref"]          
  # row_hash["creation_date"]
  # row_hash["source"]       
  # row_hash["title"]        
  # row_hash["status"]       
  # row_hash["actionnee"]       
  # row_hash["due_date"]        
  # row_hash["benefit"]        
  # row_hash["level_of_investment"]     
  def parse_actions_excel_content(consoSheet)
    # Var
    actions_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= ACTION_BEGIN_CONTENT )and (conso_row[ACTION_CELL_REF])  and (conso_row[ACTION_CELL_REF].value) and (conso_row[ACTION_CELL_REF].value.length > 0))
        row_hash = Hash.new
        row_hash[ACTION_CELL_REF_LABEL]           = conso_row[ACTION_CELL_REF].value.to_s
        row_hash[ACTION_CELL_CREATION_DATE_LABEL] = conso_row[ACTION_CELL_CREATION_DATE].to_s
        row_hash[ACTION_CELL_SOURCE_LABEL]        = conso_row[ACTION_CELL_SOURCE].to_s
        row_hash[ACTION_CELL_TITLE_LABEL]         = conso_row[ACTION_CELL_TITLE].to_s
        row_hash[ACTION_CELL_STATUS_LABEL]        = conso_row[ACTION_CELL_STATUS].to_s
        row_hash[ACTION_CELL_ACTIONNEE_LABEL]     = conso_row[ACTION_CELL_ACTIONNEE].to_s
        row_hash[ACTION_CELL_DUE_DATE_LABEL]      = conso_row[ACTION_CELL_DUE_DATE].to_s
        row_hash[ACTION_CELL_BENEFIT_LABEL]       = conso_row[ACTION_CELL_BENEFIT].to_s
        row_hash[ACTION_CELL_LEVEL_INVEST_LABEL]  = conso_row[ACTION_CELL_LEVEL_INVEST].to_s
        actions_content_array << row_hash
      end
      i += 1
    end
    return actions_content_array
  end

  # Assessments content
  # Return Array of Hashs
  # row_hash["rmt_id"]               
  # row_hash["milestone"]            
  # row_hash["detailed_presentation"]
  # row_hash["quality_gates"]        
  # row_hash["milestones_prep"]      
  # row_hash["project_setting_up"]   
  # row_hash["lessons_learnt"]       
  # row_hash["support_level"]        
  # row_hash["improve_mt"]           
  # row_hash["comments"]             
  def parse_assessments_content(consoSheet)
        # Var
    assessments_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= ASSESSMENT_BEGIN_CONTENT ) and (conso_row[ASSESSMENT_CELL_RMT_ID].to_s.size > 0))
        row_hash = Hash.new
        row_hash[ASSESSMENT_CELL_RMT_ID_LABEL]      = conso_row[ASSESSMENT_CELL_RMT_ID].to_s.gsub!('#',' ')
        row_hash[ASSESSMENT_CELL_MILESTONE_LABEL]   = conso_row[ASSESSMENT_CELL_MILESTONE].to_s
        row_hash[ASSESSMENT_CELL_DET_PRES_LABEL]    = conso_row[ASSESSMENT_CELL_DET_PRES].to_s
        row_hash[ASSESSMENT_CELL_QUAL_GATES_LABEL]  = conso_row[ASSESSMENT_CELL_QUAL_GATES].to_s
        row_hash[ASSESSMENT_CELL_M_PREP_LABEL]      = conso_row[ASSESSMENT_CELL_M_PREP].to_s
        row_hash[ASSESSMENT_CELL_PROJ_SET_UP_LABEL] = conso_row[ASSESSMENT_CELL_PROJ_SET_UP].to_s
        row_hash[ASSESSMENT_CELL_LESSONS_LABEL]     = conso_row[ASSESSMENT_CELL_LESSONS].to_s
        row_hash[ASSESSMENT_CELL_SUPP_LABEL]        = conso_row[ASSESSMENT_CELL_SUPP].to_s
        row_hash[ASSESSMENT_CELL_IMP_LABEL]         = conso_row[ASSESSMENT_CELL_IMP].to_s
        row_hash[ASSESSMENT_CELL_COMMENTS_LABEL]    = conso_row[ASSESSMENT_CELL_COMMENTS].to_s
        assessments_content_array << row_hash
      end
      i += 1
    end
    return assessments_content_array
  end
end
