class SpidersController < ApplicationController
  layout 'spider'
  
  # -------------
  # GENERAL /READ
  # -------------
  
  # Spider page for a project
  # Exemple of address : http://0.0.0.0:3000/spiders/project_spider?project_id=806&milestone_name_id=1&create_spider=0
  def project_spider
    # Search project from parameter
    id = params[:project_id]
    @project = Project.find(id)
    
    # search milestonename from parameter
    milestoneNameId = params[:milestone_name_id]
    @milestone = MilestoneName.find(milestoneNameId)
    
    # create new spider parameter
    create_spider_param = params[:create_spider]    
    
    # call generate_current_table
    generate_current_table(@project,@milestone,create_spider_param)
    # Search all spider from history (link)
    create_spider_history(@project,@milestone)
  end
  
  # History of one spider
  def project_spider_history
    # Search project for paramater
    id = params[:spider_id]
    @spider = Spider.find(id)
    # generate_table_history
    generate_table_history(@spider)
  end
  
  # -------------
  # CREATE HTML TABLE
  # -------------
  
  # Generate data for the current spider
  def generate_current_table(currentProject,currentMilestoneName,newSpiderParam)
    @currentProjectId = currentProject.id
    @currentMilestoneNameId = currentMilestoneName.id
    @pmType = Hash.new
    @questions = Hash.new
    @questions_values = Hash.new
    @spider = nil
    
    #
    # SPIDER
    # 
    
    # Search the last spider with are not consolidated
    last_spider = Spider.last(:conditions => ["project_id = ? and milestone_id= ?", currentProject.id, currentMilestoneName.id])
    
    # If not spider currently edited
    if ((!last_spider) || (last_spider.spider_consolidations.count != 0))
      # If create mode
      if (newSpiderParam == "1")
        last_spider = create_spider_object(currentProject,currentMilestoneName)
      end
    end
    
    if ((last_spider) && (last_spider.spider_consolidations.count == 0))
      @spider = last_spider
    
      #
      # QUESTIONS
      #
    
      # Search questions for this project
      # For Each PM Type
      PmType.find(:all).each{ |p|
        @pmType[p.id] = p.title
        # All Axes
        pmTypeAxe_ids = PmTypeAxe.all(:conditions => ["pm_type_id = ?", p.id]).map{ |pa| pa.id }
        # All questions
        @questions[p.id] = LifecycleQuestion.all(:conditions => ["lifecycle_id = ? and pm_type_axe_id IN (?)", currentProject.lifecycle_id, pmTypeAxe_ids],:order => "pm_type_axe_id ASC")
      }
    
      #
      # Values
      #
      last_spider.spider_values.each { |v|
        @questions_values[v.lifecycle_question_id] = v
      }
    end
  end

  # Generate data for the history spider selected
  def generate_table_history(spiderParam)
    @pmType = Hash.new
    @history = Hash.new
    # For Each PM Type
    PmType.find(:all).each{ |p|
      @pmType[p.id] = p.title
      # All Axes
      pmTypeAxe_ids = PmTypeAxe.all(:conditions => ["pm_type_id = ?", p.id]).map{ |pa| pa.id }
      # All values/questions
      @history[p.id] = SpiderValue.find(:all,
      :include => :lifecycle_question,
      :conditions => ['spider_id = ? and lifecycle_questions.pm_type_axe_id IN (?)', spiderParam.id,pmTypeAxe_ids],
      :order => "lifecycle_questions.pm_type_axe_id ASC")
    }  
  end
  
  # -------------
  # CREATE HISTORY LINKS
  # -------------
  def create_spider_history(projectSpider,milestoneNameSpider)
    @history = Array.new
    Spider.find(:all,
    :select => "DISTINCT(spiders.id),spiders.created_at",
    :joins => 'JOIN spider_consolidations ON spiders.id = spider_consolidations.spider_id',
    :conditions => ["project_id = ? and milestone_id= ?", projectSpider.id, milestoneNameSpider.id]).each { |s|
      @history.push(s)
    }
  end
  
  
  # -------------
  # CREATE MODEL SPIDER OBJECT
  # -------------
  
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


  # ---------------
  # FORMS MANAGEMENT
  # ---------------
  
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
        project_spider_consolidate(spider)
     end
     redirect_to :action=>:project_spider, :project_id=>params[:project_id], :milestone_name_id=>params[:milestone_name_id]
  end
  
  # Consolidate the spider
  def project_spider_consolidate(spiderParam)
    currentAxes = ""
    currentAxesId = 0;
    valuesTotal = 0
    valuesCount = 0
    referencesTotal = 0
    referencesCount = 0
    niCount = 0
    i = 0;
    
    SpiderValue.find(:all, 
    :joins => 'LEFT OUTER JOIN lifecycle_questions ON spider_values.lifecycle_question_id = lifecycle_questions.id',
    :conditions => ['spider_id = ?', spiderParam.id],
    :order => "lifecycle_questions.pm_type_axe_id ASC").each { |v|          
      # If new axes
      if(currentAxes != v.lifecycle_question.pm_type_axe.title)  
          if(i!=0)
            # Save data in consolidate table
            create_spider_conso(spiderParam,currentAxesId,valuesTotal,valuesCount,referencesTotal,referencesCount,niCount)             
          end
          currentAxes = v.lifecycle_question.pm_type_axe.title
          currentAxesId = v.lifecycle_question.pm_type_axe.id
          valuesTotal = 0
          valuesCount = 0
          referencesTotal = 0
          referencesCount = 0
          niCount = 0
      end
      
      if(v.note == "NI")
        niCount = niCount.to_i + 1
      else
        valuesTotal = valuesTotal.to_i + v.note.to_i
        valuesCount = valuesCount.to_i + 1
      end
      referencesTotal = referencesTotal.to_i + v.reference.to_i
      referencesCount = referencesCount.to_i + 1
      i = i + 1
    }
    # Save data of last element
    create_spider_conso(spiderParam,currentAxesId,valuesTotal,valuesCount,referencesTotal,referencesCount,niCount)
  end
  
  # Create spider consolidation
  def create_spider_conso(spiderParam, axesIdParam, valuesTotalParam,valuesCountParam,referencesTotalParam,referencesCountParam,niCountParam)
    new_spider_conso = SpiderConsolidation.new
    if(valuesCountParam != 0)
      new_spider_conso.average = valuesTotalParam / valuesCountParam
    else
      new_spider_conso.average = 0
    end
    if(referencesCountParam != 0)
      new_spider_conso.average_ref = referencesTotalParam / referencesCountParam
    else
      new_spider_conso.average_ref = 0
    end
    new_spider_conso.ni_number = niCountParam
    new_spider_conso.spider_id = spiderParam.id
    new_spider_conso.pm_type_axe_id = axesIdParam
    new_spider_conso.save
  end
  
end
