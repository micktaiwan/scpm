require 'spreadsheet'
class SpidersController < ApplicationController
  layout 'spider'
  
  # ------------------------------------------------------------------------------------
  # GENERAL /READ
  # ------------------------------------------------------------------------------------
  
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
  
  # Export excel from project
  def project_spider_export
    @project = Project.find(params[:project_id])
    @pm_type_hash = Hash.new
    @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
    
    
    # Cache for milestones and spider
    cache_milestone = Array.new
    cache_spider = Hash.new
    
    @project.milestones.each { |mi|
      # Search milestonename obj
      milestone_name_obj = MilestoneName.first(:conditions => ["title = ?", mi.name])
      cache_milestone<<milestone_name_obj
      cache_spider[milestone_name_obj.id] = Spider.last(
      :joins => 'JOIN spider_consolidations ON spiders.id = spider_consolidations.spider_id',
      :conditions => ['project_id = ? and milestone_id = ? ',@project.id,milestone_name_obj.id])
    }
    
    PmType.find(:all).each { |pm|  
      # Params
      @pm_type_hash[pm.id] = Hash.new
      @pm_type_hash[pm.id]["title"] = pm.title
      @pm_type_hash[pm.id]["axe_hash"] = Hash.new
      
      #pm.pm_type_axes.each { |axe|
      PmTypeAxe.find(:all,:include => :lifecycle_questions , :conditions => ["pm_type_id = ? and lifecycle_questions.lifecycle_id = ?", pm.id, @project.lifecycle_id]).each{ |axe|
        # Params
        @pm_type_hash[pm.id]["axe_hash"][axe.id] = Hash.new
        @pm_type_hash[pm.id]["axe_hash"][axe.id]["title"] = axe.title
        @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"] = Hash.new

        # Get milestones
        cache_milestone.each { |mi|
          # Params
          @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id] = Hash.new
          @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["title"] = mi.title
          @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["question_hash"] = Hash.new
          
          #last_spider = Spider.last(:conditions => ['project_id = ? and milestone_id = ? ',@project.id,mi.id])
          last_spider = cache_spider[mi.id]
          # Get spiders conso for this project, this milestone, this axe, and last spider
          if((last_spider) and (last_spider.spider_consolidations.count > 0))
            last_spider.spider_consolidations.each { |conso|
              if (conso.pm_type_axe_id == axe.id)
                @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["spider_conso"] = conso
              end
            }
          else
            @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["spider_conso"] = 0
          end
          
          LifecycleQuestion.all(:conditions => ["lifecycle_id = ? and pm_type_axe_id = ?",@project.lifecycle_id,axe.id] ).each{ |quest|
            # Params
            @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["question_hash"][quest.id] = Hash.new
            @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["question_hash"][quest.id]["text"] = quest.text
                  
            # Get spiders values for this project, this milestone, this axe, and last spider
            if(last_spider)
              last_spider.spider_values.each { |sv| 
                if (sv.lifecycle_question_id == quest.id)
                  @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["question_hash"][quest.id]["spider_value"] = sv
                end
              }
            else
              @pm_type_hash[pm.id]["axe_hash"][axe.id]["milestone_hash"][mi.id]["question_hash"][quest.id]["spider_value"] = 0
            end
         }
        }
      }
    }
   
    headers['Content-Type']         = "application/vnd.ms-excel"
    headers['Content-Disposition']  = 'attachment; filename="Summary.xls"'
    headers['Cache-Control']        = ''
    render(:layout=>false)
  end
  
  def project_spider_import
  end
  
  def do_spider_upload
    
    # INDEX OF COLUMNS IN EXCEL ------------------------
    @practiceStartColumn = 9
    @practiceEndColumn = 35
    @deliverableStartColumn = 36
    @deliverableEndColumn = 62
    
    # LOAD FILE --------------------------------- 
    consoSheet = load_spider_excel_file(params[:upload])
    
    # ANALYSE HEADER OF FILE ---------------------------------
    axesHash = analyze_spider_excel_file_header(consoSheet)
    
    # ANALYSE CONSOS OF FILE ---------------------------------
    projectsArray = analyze_spider_excel_file_conso(consoSheet, axesHash)
    
    # IMPORT DATA IN BDD ---------------------------------
    @projectsNotFound = Array.new
    @milestonesNotFound = Array.new
    @axesNotFound = Array.new
    @projectsAlreadyImported = Array.new
    
    # For each projects
    projectsArray.each { |project| 
         	
    	# Search project in BAM
    	bam_project = Project.last(:conditions=>["name = ?", project["title"]])
    	if(bam_project != nil)
    	  
    	  # Search milestone
    	  milestoneList = Array.new
    	  if (project["milestone"].count('-') > 0)
    	    milestoneList = project["milestone"].split('-')
    	  else
    	    milestoneList << project["milestone"]
    	  end 
    	  
    	  # For each milestones of project in BAM
    	  milestoneList.each { |project_milestone|
    	    
    	    bam_milestone = Milestone.last(:conditions =>["name = ? and project_id = ?", project_milestone, bam_project.id])
    	    
    	    if(bam_milestone != nil)
    	      # Search milestone Name
    	      bam_milestone_name = MilestoneName.first(:conditions => ["title = ?",bam_milestone.name])
    	      # Check if spider not already exist
    	      utc_date = Time.zone.parse(project["date"]).utc
    	      spider_exist = Spider.first(:conditions => ["project_id = ? and milestone_id = ? and created_at = ?",bam_project.id,bam_milestone_name.id,utc_date])
    	      if(spider_exist == nil)
    	      
      	      # Create Spider for this project
      	      new_spider = create_spider_object(bam_project,bam_milestone_name)
      	      new_spider.created_at = project["date"]
      	      new_spider.save
    	      
      	      # For each conso
      	      project["conso"].each do |conso|
    	        
      	        axe_title = conso[0]
      	        if (axe_title[-1,1] == " ")
      	          axe_title = axe_title[0..-2]
      	        end
      	        if(axe_title[0,1] == " ")
      	          axe_title = axe_title[1..-1]
      	        end
    	          pm_type = axesHash[conso[1]["column_ids"].last.to_i]["type"]
    	        
      	        if(conso[1]["column_ids"][2].to_i <= @deliverableEndColumn)
          	      # Search type
          	      bam_pm_type = PmType.first(:conditions => ["title LIKE ?", "%"+pm_type+"%"])
        	        # Search Axes
        	        bam_axe = PmTypeAxe.first(:conditions => ["pm_type_id = ? and title LIKE ?", bam_pm_type.id, "%"+axe_title+"%"])
        	        # Axes if not found
        	        if (bam_axe != nil)
        	          # Add spider conso
        	          create_spider_conso(new_spider,bam_axe.id,conso[1]["values"][0],1,conso[1]["values"][1],1,conso[1]["values"][2])
        	        else
        	          @axesNotFound << "Project : "+ bam_project.name + " - Milestone : " + project_milestone + " - Axe : " + axe_title + " not found."
        	        end
        	      end
      	      end
        	  else
        	    @projectsAlreadyImported << "Project : "+ bam_project.name + " - Milestone : " + project_milestone + " : Already imported."
        	  end
    	    else
    	      @milestonesNotFound << "Project : "+ bam_project.name + " - Milestone : " + project_milestone + " not found."
    	    end 
    	  }
    	else
    	  @projectsNotFound << "Project " + project["title"] + " not found"
    	end
    }
  end
  
  # ------------------------------------------------------------------------------------
  # IMPORT FUNCTIONS
  # ------------------------------------------------------------------------------------

  # Load excel file and return the worksheet named "Conso"
  def load_spider_excel_file(post)
    redirect_to '/spiders/project_spider_import' and return if post.nil? or post['datafile'].nil?
    Spreadsheet.client_encoding = 'UTF-8'
    doc = Spreadsheet.open post['datafile']
    consoSheet = doc.worksheet 'Conso'
    return consoSheet
  end
  
  # Read the second line of the excels and return an identification of Pm type and axe for each columns
  # Return value : axesHash
  # Format : axesHash[column_index] = hash
  # axesHash[column_index]["title"] = Title of axes
  # axesHash[column_index]["type"] = Title of PM Type
  def analyze_spider_excel_file_header(consoSheet)
    # Second line of excel / Axes headers
    # Params
    subHeaderIndex = 0
    lastAxeName = ""
    axesHash = Hash.new
    
    # Each Cells
    consoSheet.row(1).each do |sub_header_cell|

    	type = ""
    	if ((subHeaderIndex >= @practiceStartColumn) and (subHeaderIndex <= @practiceEndColumn))
    		type = "Practice"
    	elsif ((subHeaderIndex >= @deliverableStartColumn) and (subHeaderIndex <= @deliverableEndColumn))
    		type = "Deliverable"
    	end

      # If new axe
    	if ((type != "") and (sub_header_cell.to_s != "") and (lastAxeName != sub_header_cell.to_s))
    		axesHash[subHeaderIndex] = Hash.new
    		axesHash[subHeaderIndex]["type"] = type
    		axesHash[subHeaderIndex]["title"] = sub_header_cell.to_s
    		lastAxeName = sub_header_cell.to_s
    	elsif((type != "") and (sub_header_cell.to_s == ""))
    		axesHash[subHeaderIndex] = Hash.new
    		axesHash[subHeaderIndex]["type"] = type
    		axesHash[subHeaderIndex]["title"] = lastAxeName
    	end
    	subHeaderIndex += 1
    end
    return axesHash
  end
  
  # Read the content of excel file and return an array of hash
  # Return value : projectsArray
  # Format : projectsArray[index_array] = hash
  # projectsArray[index_array]["title"] = Name of project
  # projectsArray[index_array]["version"] = Version of project
  # projectsArray[index_array]["milestone"] = Milestone of project (can contain a string of multiple milestones. Ex : M1-M3)
  # projectsArray[index_array]["date"] = Date of project
  # projectsArray[index_array]["conso"] = Hash
  # projectsArray[index_array]["conso"][axe_name] = Hash
  # projectsArray[index_array]["conso"]["values"] = Array of values (Note + Ref + nb ni)
  # projectsArray[index_array]["conso"]["column_ids"] = Array of column id (Note column id + Ref column id + nb ni column id)
  def analyze_spider_excel_file_conso(consoSheet,axesHash)
    # Conso lines
   projectsArray = Array.new
   indexRow = 0
   # For each row
   consoSheet.each do |conso_row|
   	# If project name
   	if ((indexRow > 2) and (conso_row[3].to_s != ""))
   		projectHash = Hash.new
   		projectHash["title"] = conso_row[3].to_s
   		projectHash["version"] = conso_row[4].to_s
   		projectHash["milestone"] = conso_row[5].to_s
   		year = conso_row[8].to_i
   		year_str = year.to_s
   		month = conso_row[7].to_i
   		month_str = month.to_s
   		if (month < 10)
   		  month_str = "0"+month.to_s
   		end
   		day = conso_row[6].to_i
   		day_str = day.to_s
   		if (day < 10)
   		  day_str = "0"+day.to_s
   		end
   		projectHash["date"] = year_str+ "-" + month_str + "-" + day_str + " 00:00:00"
      projectHash["conso"] = Hash.new

   		columnIndex = 9
   		column_last_axe_name = ""
   		# For each question values/ref/ni
   		while columnIndex <= conso_row.count and columnIndex <= @deliverableEndColumn
         if(column_last_axe_name != axesHash[columnIndex]["title"])
           projectHash["conso"][axesHash[columnIndex]["title"]] = Hash.new
           projectHash["conso"][axesHash[columnIndex]["title"]]["values"] = Array.new
           projectHash["conso"][axesHash[columnIndex]["title"]]["column_ids"] = Array.new
           column_last_axe_name = axesHash[columnIndex]["title"]
         end

         projectHash["conso"][axesHash[columnIndex]["title"]]["values"] << conso_row[columnIndex].to_s
         projectHash["conso"][axesHash[columnIndex]["title"]]["column_ids"] << columnIndex.to_s
   			columnIndex += 1
   		end
   		projectsArray << projectHash
   	end
   	indexRow += 1
   end
   return projectsArray
  end
  
  # ------------------------------------------------------------------------------------
  # CREATE HTML TABLE
  # ------------------------------------------------------------------------------------
  
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
    @consolidationData = Hash.new
    @axesConsolidations = Hash.new
    
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
      
      @consolidationData[p.id] = SpiderConsolidation.find(:all,
      :include => :pm_type_axe,
      :conditions => ['spider_id = ? and pm_type_axes.pm_type_id = ?', spiderParam.id,p.id],
      :order => "pm_type_axes.id ASC")
      
      @consolidationData[p.id].each { |c|
        @axesConsolidations[c.pm_type_axe_id] = Hash.new
        @axesConsolidations[c.pm_type_axe_id]["avg_note"] = c.average.to_s
        @axesConsolidations[c.pm_type_axe_id]["avg_ref"] = c.average_ref.to_s
        @axesConsolidations[c.pm_type_axe_id]["ni_nb"] =  c.ni_number.to_s
      }      
    }  
  end
  
  # ------------------------------------------------------------------------------------
  # CREATE HISTORY LINKS
  # ------------------------------------------------------------------------------------
  def create_spider_history(projectSpider,milestoneNameSpider)
    @history = Array.new
    Spider.find(:all,
    :select => "DISTINCT(spiders.id),spiders.created_at",
    :joins => 'JOIN spider_consolidations ON spiders.id = spider_consolidations.spider_id',
    :conditions => ["project_id = ? and milestone_id= ?", projectSpider.id, milestoneNameSpider.id]).each { |s|
      @history.push(s)
    }
  end
  
  
  # ------------------------------------------------------------------------------------
  # CREATE MODEL SPIDER OBJECT
  # ------------------------------------------------------------------------------------
  
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
      else
        new_spider_value.reference = "NI"
      end
      
      new_spider_value.save
    }
    return new_spider
  end


  # ------------------------------------------------------------------------------------
  # FORMS MANAGEMENT
  # ------------------------------------------------------------------------------------
  
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
        valuesTotal = valuesTotal.to_f + 0
        valuesCount = valuesCount.to_i + 1
      else
        valuesTotal = valuesTotal.to_f + v.note.to_f
        valuesCount = valuesCount.to_i + 1
      end
      referencesTotal = referencesTotal.to_f + v.reference.to_f
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
      new_spider_conso.average = valuesTotalParam.to_f / valuesCountParam.to_f
    else
      new_spider_conso.average = 0
    end
    if(referencesCountParam != 0)
      new_spider_conso.average_ref = referencesTotalParam.to_f / referencesCountParam.to_f
    else
      new_spider_conso.average_ref = 0
    end
    new_spider_conso.ni_number = niCountParam
    new_spider_conso.spider_id = spiderParam.id
    new_spider_conso.pm_type_axe_id = axesIdParam
    new_spider_conso.save
  end
    
end
