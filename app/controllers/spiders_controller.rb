class SpidersController < ApplicationController
  def index
    #project_spider_save("ff","rr")
  end

  #
  # GENERAL /READ
  #
  
  # Spider page for a project
  # Exemple of address : http://0.0.0.0:3000/spiders/project_spider?project_id=806&milestone_name_id=1
  def project_spider
    
    # Search project from parameter
    id = params[:project_id]
    @project = Project.find(id)
    
    # search milestonename from parameter
    milestoneNameId = params[:milestone_name_id]
    @milestone = MilestoneName.find(milestoneNameId)
    
    # call generate_current_table
    generate_current_table(@project,@milestone)
    # Search all spider from history (link)
  end
  
  # History of one spider
  def project_spider_history
    # Search project for paramater
    # Search milestonename from paramater
    # generate_table_history
  end
  
  
  # Generate data for the current spider
  def generate_current_table(currentProject,currentMilestoneName)
    @currentProjectId = currentProject.id
    @currentMilestoneNameId = currentMilestoneName.id
    
    #
    # SPIDER
    # 
    
    # Search the last spider with are not consolidated
    last_spider = Spider.last(:conditions => ["project_id = ? and milestone_id= ?", currentProject.id, currentMilestoneName.id])
    
    # If not, create new
    if (!last_spider)
      last_spider = create_spider_object(currentProject,currentMilestoneName)
    end
    @spider = last_spider
    
    #
    # QUESTIONS
    #
    
    # Search questions for this project
    @questions = Hash.new
    # For Each PM Type
    PmType.find(:all).each{ |p|
      # All Axes
      pmTypeAxe_ids = PmTypeAxe.all(:conditions => ["pm_type_id = ?", p.id]).map{ |pa| pa.id }
      # All questions
      @questions[p.id] = LifecycleQuestion.all(:conditions => ["lifecycle_id = ? and pm_type_axe_id IN (?)", currentProject.lifecycle_id, pmTypeAxe_ids],:order => "pm_type_axe_id ASC")
    }
    
    #
    # Values
    #
    @questions_values = Hash.new
    last_spider.spider_values.each { |v|
      @questions_values[v.lifecycle_question_id] = v
    }

  end
  
  # Create spider object with questions
  def create_spider_object(projectSpider,milestoneNameSpider)
    new_spider = Spider.new()
    new_spider.project_id = projectSpider.id
    new_spider.milestone_id = milestoneNameSpider.id
    new_spider.save
    
    # Generate Spider_responses
    LifecycleQuestion.all(:conditions => ["lifecycle_id = ?", projectSpider.lifecycle_id]).each { |q|
      # Get reference for this question and milestone
      new_question_reference = QuestionReference.first(:conditions => ["question_id = ? and milestone_id = ?", q.id, milestoneNameSpider.id])
      
      # Creation question value
      new_spider_value = SpiderValue.new
      new_spider_value.lifecycle_question_id = q.id
      new_spider_value.spider_id = new_spider.id
      if(new_question_reference)
        new_spider_value.reference = new_question_reference.note
      end
      new_spider_value.save
    }
    return new_spider
  end
  
  # Generate data for the history spider selected
  def generate_table_history(project,milestoneName,creationDate)
    # Search project and its lifecycle
    # Search questions for this project
    # Search responses (and references) for each Question
    # make array of data
  end


  #
  # FORMS MANAGEMENT
  #
  
  # Save spider
  def update_spider
      spider = Spider.find(params[:spider_id])
      spiderValues = params[:spiderquest]
      spiderValues.each { |h|
        currentQuestion = SpiderValue.find(h[0])
        currentQuestion.note = h[1].to_s
        currentQuestion.save
      }
      if(params[:consolidate_spider] == "1")
        #valuesByAxeHash = Hash.new
        #referencesByAxeHash = Hash.new
        #NiByAxeHash = Hash.new
        
        currentAxes = ""
        valuesTotal = 0
        valuesCount = 0
        referencesTotal = 0
        referencesCount = 0
        niTotal = 0
        i = 0;
        SpiderValue.find(:all, :joins => 'LEFT OUTER JOIN lifecycle_questions ON spider_values.lifecycle_question_id = lifecycle_questions.id', :conditions => ['spider_id = ?', spider.id],:order => "lifecycle_questions.pm_type_axe_id ASC").each { |v|
          Rails.logger.info("---------------------------------------->"+v.id.to_s)
          
          if(currentAxes != v.lifecycle_question.pm_type_axe.title)
              if(i!=0)
                # Save data in consolidate table
                Rails.logger.info("--------------------------------> SAVE "+ currentAxes + "valuestotal = "+ valuesTotal.to_s + "values Count = "+ valuesCount.to_s)
              end
              
              currentAxes = v.lifecycle_question.pm_type_axe.title
              valuesTotal = 0
              valuesCount = 0
              referencesTotal = 0
              referencesCount = 0
              niCount = 0
          end
          
          if(v.note == "NI")
            niCount.to_i = niCount.to_i + 1
          else
            valuesTotal = valuesTotal.to_i + v.note.to_i
            valuesCount = valuesCount.to_i + 1
          end
          referencesTotal = referencesTotal.to_i + v.reference.to_i
          referencesCount = referencesCount.to_i + 1
          i = i + 1
        }
      end
      
      
      redirect_to :action=>:project_spider, :project_id=>params[:project_id], :milestone_name_id=>params[:milestone_name_id]
  end
  
  # Consolidate the spider
  def project_spider_consolidate
    
  end
  
  # Save the spider
  def project_spider_save
  end
  
  
end
