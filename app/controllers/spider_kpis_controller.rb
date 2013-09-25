class SpiderKpisController < ApplicationController
  layout "tools_spider", :except => [:generate_kpi_charts_data, :generate_kpi_export]
  
  # ------------------------------------------------------------------------------------
  # ACTIONS
  # ------------------------------------------------------------------------------------
  #http://0.0.0.0:3000/spiders/kpi_charts_by_pm_types?lifecycle_id=1&workstream=0&milestone_name_id=0
  def kpi_charts_by_pm_types 
    @chart_type_param = "classic"
    @kpi_type_param = "pm_type" 
    kpi_prepare_parameters
    render :kpi_charts
  end
  
  def kpi_charts_by_axes  
    @chart_type_param = "classic"
    @kpi_type_param = "pm_type_axe"
    kpi_prepare_parameters
    render :kpi_charts
  end
  
  def kpi_cumul_charts_by_pm_types  
    @chart_type_param = "cumul"
    @kpi_type_param = "pm_type" 
    kpi_prepare_parameters
    render :kpi_charts
  end
  
  def kpi_cumul_charts_by_axes   
    @chart_type_param = "cumul"
    @kpi_type_param = "pm_type_axe"
    kpi_prepare_parameters
    render :kpi_charts
  end

 def generate_kpi_export
    begin
    # ----------------------------------------------------------
    # PARAMS
    # ----------------------------------------------------------
    @excel_data = Array.new

    # Lifecycle
    @lifecycle_id       = params[:lifecycle_id]
    lifecycle_object    = Lifecycle.find(@lifecycle_id)
    lifecycle_title     = lifecycle_object.name

    # Workstream
    @workstream         = params[:workstream]

    # Milestone
    @milestone_name_id  = params[:milestone_name_id]
    milestone_title     = ""
    if ((@milestone_name_id != nil) and (@milestone_name_id != "0"))
      milestone_title   = MilestoneName.find(@milestone_name_id)
    end

    # Begin/End date
    @begin_date = "2013-01-01"
    @end_date   = DateTime.now.year.to_s+"-"+DateTime.now.month.to_s+"-"+DateTime.now.day.to_s
    if (params[:begin_date])
      @begin_date  = params[:begin_date]
    end
    if (params[:end_date])
      @end_date  = params[:end_date]
    end

    # ----------------------------------------------------------
    # AXES
    # ----------------------------------------------------------
    query = 'SELECT DISTINCT(p.id) FROM pm_type_axes as p, lifecycle_questions as lc, pm_type_axe_excels as px   
        WHERE p.id = lc.pm_type_axe_id 
        AND p.id = px.axe_id
        AND lc.lifecycle_id = ' + lifecycle_object.id.to_s + ' 
         ORDER BY px.excel_position'
    pm_type_axes_id = Array.new
    ActiveRecord::Base.connection.execute(query).each do |query_data|
      pm_type_axes_id << query_data[0].to_i
    end
    pm_type_axes_id_join = pm_type_axes_id.join(",")
    axes          = PmTypeAxe.find(:all,:conditions => ["id in (?)",pm_type_axes_id_join.split(',')])
    excel_columns = PmTypeAxeExcel.find(:all, :conditions => ["lifecycle_id = ? and axe_id IN (?)", @lifecycle_id.to_s, pm_type_axes_id_join.split(',')], :order => "excel_position")
    @excel_columns_title = Array.new
    @excel_columns_title << "Project Name" << "Project Workstream" << "Milestone" << "Year" << "Month" << "day"
    excel_columns.each do |excel_column|
      for i in 1..3
        @excel_columns_title << excel_column.pm_type_axe.pm_type.title + "-" + excel_column.pm_type_axe.title
      end
    end
    @excel_columns_title 

    # ----------------------------------------------------------
    # DATES CALCULCATION
    # ----------------------------------------------------------
    b_date_split        = @begin_date.split("-")
    e_date_split        = @end_date.split("-")
    b_date              = Date.strptime(b_date_split[0]+" "+b_date_split[1], "%Y %m")
    e_date              = Date.strptime(e_date_split[0]+" "+e_date_split[1], "%Y %m")
    
    end_dateTime        = e_date.to_time
    end_dateTime_final  = end_dateTime - 1.month #we will show one month before the selection

    sql_query_end       = end_dateTime.strftime("%Y-%m-01 00:00")  
    last_month_ref      = end_dateTime_final.month   
    last_year_ref       = end_dateTime_final.year 

    sql_query_begin     = b_date.strftime("%Y-%m-01 00:00:00")
    first_month_ref     = b_date.strftime("%m")   
    first_year_ref      = b_date.strftime("%Y")

    # ----------------------------------------------------------
    # GET SPIDERS
    # ----------------------------------------------------------
    spiders_conditions =  "spiders.created_at >= '" + sql_query_begin + "' AND spiders.created_at < '" + sql_query_end + "'"
    spiders_conditions += " AND projects.lifecycle_id = '" + @lifecycle_id.to_s + "'"
    
    if ((@workstream != nil) && (@workstream != "0"))
      spiders_conditions += " AND projects.workstream = '" + @workstream.to_s + "'"
    end
    if ((@milestone_name_id != nil) && (@milestone_name_id != "0"))
      spiders_conditions += " AND spiders.milestone_id = '" + @milestone_name_id.to_s + "'"
    end
    spiders_consolidated = Spider.find(:all, :include => [:project => [:lifecycle_object]], :conditions=>spiders_conditions)


    # ----------------------------------------------------------
    # GET DATA FOR EACH SPIDERS
    # ----------------------------------------------------------
    # For each spider (from spiders_consolidated)
    spiders_consolidated.each do |spider_consolidated|

      # spider_consolidated
      spider_hash = Hash.new
      spider_hash["project_name"]       = spider_consolidated.project.name    
      spider_hash["project_workstream"] = spider_consolidated.project.workstream  
      spider_hash["milestone"]          = spider_consolidated.milestone
      spider_hash["year"]               = spider_consolidated.created_at.year
      spider_hash["month"]              = spider_consolidated.created_at.month
      spider_hash["day"]                = spider_consolidated.created_at.day

      #excel_columns
      spider_axe_values = Array.new
      excel_columns.each do |excel_column|
        spiderConsolidation = SpiderConsolidation.find(:first, :conditions => ["spider_id = ? and pm_type_axe_id = ?", spider_consolidated.id, excel_column.axe_id])
        if spiderConsolidation
          spider_axe_values << spiderConsolidation.average << spiderConsolidation.average_ref << spiderConsolidation.ni_number
        else
          spider_axe_values << "NA" << "NA" << "NA"
        end
      end
      spider_hash["axe_values"]       = spider_axe_values
      @excel_data << spider_hash

    end
     
    # ----------------------------------------------------------
    # EXCEL
    # ---------------------------------------------------------- 
    excel_name = "kpi_export_" + lifecycle_object.name + ".xls"
    @xml = Builder::XmlMarkup.new(:indent => 1)
    headers['Content-Type']         = "application/vnd.ms-excel"
    headers['Content-Disposition']  = 'attachment; filename="' + excel_name + '"'
    headers['Cache-Control']  

    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end  
  end


  def generate_kpi_charts_data

    # PARAMS --------------------------------- 
    @lifecycle_id       = params[:lifecycle_id]
    lifecycle_object    = Lifecycle.find(@lifecycle_id)
    lifecycle_title     = lifecycle_object.name
    @workstream         = params[:workstream]
    @milestone_name_id  = params[:milestone_name_id]
    milestone_title     = ""
    if ((@milestone_name_id != nil) and (@milestone_name_id != "0"))
      milestone_title   = MilestoneName.find(@milestone_name_id)
    end
    @begin_date = "2013-01-01"
    @end_date   = DateTime.now.year.to_s+"-"+DateTime.now.month.to_s+"-"+DateTime.now.day.to_s
    if (params[:begin_date])
      @begin_date  = params[:begin_date]
    end
    if (params[:end_date])
      @end_date  = params[:end_date]
    end

    # CHART TYPE --------------------------------- 
    @kpi_type = ""
    if (@kpi_type_param != nil)
      @kpi_type = @kpi_type_param
    else
      @kpi_type = params[:kpi_type]
    end
    charts_element = Array.new
    if (@kpi_type == "pm_type")
      charts_element = PmType.all
    else
        query = 'SELECT DISTINCT(p.id) FROM pm_type_axes as p, lifecycle_questions as lc   
        WHERE p.id = lc.pm_type_axe_id 
        AND lc.lifecycle_id = ' +lifecycle_object.id.to_s
        pm_type_axes_id = Array.new
        ActiveRecord::Base.connection.execute(query).each do |query_data|
          pm_type_axes_id << query_data[0].to_i
        end
        pm_type_axes_id_join = pm_type_axes_id.join(",")
        charts_element = PmTypeAxe.find(:all,:conditions => ["id in (?)",pm_type_axes_id_join.split(',')])
    end

    @chart_type = ""
    if(@chart_type_param != nil)
      @chart_type = @chart_type_param
    else
      @chart_type = params[:chart_type]
    end

    spiders_consolidated = get_spiders_consolidated(@lifecycle_id,@workstream, @milestone_name_id, @begin_date, @end_date)
    

    # MONTHS CALCUL --------------------------------- 
    b_date_split  = @begin_date.split("-")
    e_date_split  = @end_date.split("-")
    b_date        = Date.strptime(b_date_split[0]+" "+b_date_split[1], "%Y %m")
    e_date        = Date.strptime(e_date_split[0]+" "+e_date_split[1], "%Y %m")
    
    # @months_array = Array.new
    end_dateTime        = e_date.to_time
    end_dateTime_final  = end_dateTime - 1.month #we will show one month before the selection

    sql_query_end   = end_dateTime.strftime("%Y-%m-01 00:00")  
    last_month_ref  =  end_dateTime_final.month   
    last_year_ref   = end_dateTime_final.year 

    sql_query_begin = b_date.strftime("%Y-%m-01 00:00:00")
    first_month_ref =  b_date.strftime("%m")   
    first_year_ref  = b_date.strftime("%Y")


    # REQUEST PARAMS--------------------------------- 

    @charts_data           = Hash.new
    @charts_reference_data = Hash.new
    @titles_data           = Hash.new

    # REQUEST VALUE--------------------------------- 

    # MULTIPLE GROUP BY : Seem broken (https://rails.lighthouseapp.com/projects/8994/tickets/497-activerecord-calculate-broken-for-multiple-fields-in-group-option)
    # So I use a SQL Query (yes, it's ugly in a RoR project)
    
    charts_element.each do |chart_element|

      @charts_data[chart_element.id.to_s] = Array.new
      charts_data_by_date                 = Hash.new

      #
      # Query Data
      #
      query = "SELECT avg(sc.average), avg(sc.average_ref), MONTH(sc.created_at),YEAR(sc.created_at) 
      FROM spider_consolidations sc,  pm_type_axes pta
      WHERE sc.pm_type_axe_id = pta.id
      AND sc.spider_id IN (" + spiders_consolidated.join(",") + ")"
      query += " AND sc.created_at >= '" + sql_query_begin.to_s + "'"
      query += " AND sc.created_at < '" + sql_query_end.to_s + "'" # < and not <= Before the date is the next month at 00:00:00
      
      if (@kpi_type == "pm_type")
        query += " AND pta.pm_type_id = " + chart_element.id.to_s
      else
        query += " AND pta.id = " + chart_element.id.to_s
      end
      
      query += " GROUP BY MONTH(created_at),YEAR(created_at) 
      ORDER BY YEAR(created_at),MONTH(created_at)";
      
      # 
      # Save query data in hash[month-year]
      #
      ActiveRecord::Base.connection.execute(query).each do |query_data|
        charts_data_by_date[query_data[2]+"-"+query_data[3]] = query_data
      end
      
      #
      # Set final Values in @chart_data
      #
      month_index = 0
      # For each month between two dates
      (Date.new(first_year_ref.to_i, first_month_ref.to_i)..Date.new(last_year_ref.to_i, last_month_ref.to_i)).select {|d| 

        # if new month to manage
        if (month_index.to_i != d.month.to_i)

          # If we have a value for this month-year
          if(charts_data_by_date[d.month.to_s+"-"+d.year.to_s] != nil)
            @charts_data[chart_element.id.to_s] << charts_data_by_date[d.month.to_s+"-"+d.year.to_s]
          # If we haven't a value for this month-year
          else
            unassigned_month = Array.new<<0<<0<<d.month.to_i<<d.year.to_i # << Val << Ref << Month << Year
            @charts_data[chart_element.id.to_s] << unassigned_month
          end

          month_index = d.month
        end
      }
      
      #
      # Set title
      #

      title = lifecycle_title
      if ((@workstream != nil) and (@workstream != "0"))
        title += " - " + @workstream
      end
      if ((milestone_title != nil) and (milestone_title != ""))
        title += " - " + milestone_title.title
      end
      @titles_data[chart_element.id.to_s] = title + " - " + chart_element.title  
    end



    # RENDER --------------------------------- 

    if(@kpi_type_param == nil)
      render :layout => false     
    end
  end


  def generate_kpi_cumul_charts_data

    # PARAMS --------------------------------- 
    @lifecycle_id       = params[:lifecycle_id]
    lifecycle_object    = Lifecycle.find(@lifecycle_id)
    lifecycle_title     = lifecycle_object.name
    @workstream         = params[:workstream]
    @milestone_name_id  = params[:milestone_name_id]
    milestone_title     = ""
    if ((@milestone_name_id != nil) and (@milestone_name_id != "0"))
      milestone_title = MilestoneName.find(@milestone_name_id)
    end
    @begin_date = "2013-01-01"
    @end_date   = DateTime.now.year.to_s+"-"+DateTime.now.month.to_s+"-"+DateTime.now.day.to_s
    if (params[:begin_date])
      @begin_date  = params[:begin_date]
    end
    if (params[:end_date])
      @end_date  = params[:end_date]
    end

    # CHART TYPE --------------------------------- 
    @kpi_type = ""
    if (@kpi_type_param != nil)
      @kpi_type = @kpi_type_param
    else
      @kpi_type = params[:kpi_type]
    end
    charts_element = Array.new
    if (@kpi_type == "pm_type")
      charts_element = PmType.all
    else
      query = 'SELECT DISTINCT(p.id) FROM pm_type_axes as p, lifecycle_questions as lc   
      WHERE p.id = lc.pm_type_axe_id 
      AND lc.lifecycle_id = ' +lifecycle_object.id.to_s
      pm_type_axes_id = Array.new
      ActiveRecord::Base.connection.execute(query).each do |query_data|
        pm_type_axes_id << query_data[0].to_i
      end
      pm_type_axes_id_join = pm_type_axes_id.join(",")
      charts_element = PmTypeAxe.find(:all,:conditions => ["id in (?)",pm_type_axes_id_join.split(',')])
    end

    @chart_type = ""
    if(@chart_type_param != nil)
      @chart_type = @chart_type_param
    else
      @chart_type = params[:chart_type]
    end

    spiders_consolidated = get_spiders_consolidated(@lifecycle_id,@workstream, @milestone_name_id, @begin_date, @end_date)
    
    # MONTHS CALCUL --------------------------------- 
    b_date_split  = @begin_date.split("-")
    e_date_split  = @end_date.split("-")
    b_date        = Date.strptime(b_date_split[0]+" "+b_date_split[1], "%Y %m")
    e_date        = Date.strptime(e_date_split[0]+" "+e_date_split[1], "%Y %m")
    
    # @months_array = Array.new
    end_dateTime        = e_date.to_time
    end_dateTime_final  = end_dateTime - 1.month #we will show one month before the selection

    sql_query_end   = end_dateTime.strftime("%Y-%m-01 00:00")  
    last_month_ref  =  end_dateTime_final.month   
    last_year_ref   = end_dateTime_final.year 

    sql_query_begin = b_date.strftime("%Y-%m-01 00:00:00")
    first_month_ref =  b_date.strftime("%m")   
    first_year_ref  = b_date.strftime("%Y")


    # REQUEST --------------------------------- 
    @charts_data = Hash.new
    charts_data_temp = Hash.new
    @titles_data = Hash.new
    charts_element.each do |chart_element|

      charts_data_temp[chart_element.id.to_s] = Array.new
      charts_data_by_date                     = Hash.new

      #
      # Query Data
      #
      query = "SELECT sum(sc.average),count(sc.average),sum(sc.average_ref),count(sc.average_ref),MONTH(sc.created_at),YEAR(sc.created_at) 
      FROM spider_consolidations sc,  pm_type_axes pta
      WHERE sc.pm_type_axe_id = pta.id
      AND sc.spider_id IN (" + spiders_consolidated.join(",") + ")"
      query += " AND sc.created_at >= '" + sql_query_begin.to_s + "'"
      query += " AND sc.created_at < '" + sql_query_end.to_s + "'"
      if (@kpi_type == "pm_type")
        query += " AND pta.pm_type_id = " + chart_element.id.to_s
      else
        query += " AND pta.id = " + chart_element.id.to_s
      end
      query += " GROUP BY MONTH(created_at),YEAR(created_at) 
      ORDER BY YEAR(created_at),MONTH(created_at)";
      
      
      #
      # Save query data in hash[month-year]
      #
      ActiveRecord::Base.connection.execute(query).each do |query_data|
        charts_data_by_date[query_data[4]+"-"+query_data[5]] = query_data
      end
      
      #
      # Set final Values in charts_data_temp
      #
      month_index = 0
      # For each month between two dates
      (Date.new(first_year_ref.to_i, first_month_ref.to_i)..Date.new(last_year_ref.to_i, last_month_ref.to_i)).select {|d| 

        # if new month to manage
        if (month_index.to_i != d.month.to_i)

          # If we have a value for this month-year
          if(charts_data_by_date[d.month.to_s+"-"+d.year.to_s] != nil)
            charts_data_temp[chart_element.id.to_s] << charts_data_by_date[d.month.to_s+"-"+d.year.to_s]
          # If we haven't a value for this month-year
          else
            unassigned_month = Array.new<<0<<0<<0<<0<<d.month.to_i<<d.year.to_i # sum/count/sum ref/count ref/month/year
            charts_data_temp[chart_element.id.to_s] << unassigned_month
          end

          month_index = d.month
        end
      }
      
      # 
      # Set title
      #
      title = lifecycle_title
      if ((@workstream != nil) and (@workstream != "0"))
        title += " - " + @workstream
      end
      if ((milestone_title != nil) and (milestone_title != ""))
        title += " - " + milestone_title.title
      end
      
      @titles_data[chart_element.id.to_s] = title + " - " + chart_element.title  
    end
    
    # CUMUL CALCULATION --------------------------------- 
    # c[0] = id of chart element (id of pm type or id of axes)
    # c[1] =  Array of (sum/count/sum ref/count ref/month/year)
    # c[1] == cc
    # cc[0] sum avg
    # cc[1] count avg
    # cc[2] sum avg ref
    # cc[3] count avg ref
    # cc[4] month
    # cc[5] year
    # new_c[0] avg sum
    # new_c[1] avg sum ref
    # new_c[2] month
    # new_c[3] year
    # cc == new_c after format
    # Each chart
    charts_data_temp.each do |c|

      # Params
      @charts_data[c[0]] = Array.new
      sum_avg       = 0
      sum_count     = 0
      sum_avg_ref   = 0
      sum_count_ref = 0
      last_avg      = -1
      last_avg_ref  = -1

      # Each values
      c[1].each do |cc|
        new_c = Array.new # New set of values (sum/count/month/year)

        #
        # Calcul cumul sum
        #
        # First loop, we don't have a last_avg value
        if(last_avg == -1)
            count_to_divise = cc[1].to_f
            if(count_to_divise == 0)
              new_c[0] = 0
            else
              new_c[0] = cc[0].to_f / count_to_divise
            end
            last_avg = new_c[0]

        # The sum is to 0
        elsif (cc[0].to_f == 0)
            new_c[0] = last_avg
            last_avg = last_avg

        # The last sum was to 0
        elsif(last_avg == 0)
            count_to_divise = cc[1].to_f
            if(count_to_divise == 0)
              new_c[0] = 0
            else
              new_c[0] = cc[0].to_f / count_to_divise
            end
            last_avg = new_c[0]

        # If the sum and last sum is > 0
        else
            new_c[0] = ((sum_avg.to_f + cc[0].to_f).to_f / (sum_count.to_f + cc[1].to_f).to_f)
            last_avg = new_c[0]
        end  

        #
        # Calcul cumul sum ref
        #
        # First loop, we don't have a last_avg value
        if(last_avg_ref == -1)
            count_to_divise = cc[3].to_f
            if(count_to_divise == 0)
              new_c[1] = 0
            else
              new_c[1] = cc[2].to_f / count_to_divise
            end
            last_avg_ref = new_c[1]

        # The sum is to 0
        elsif (cc[2].to_f == 0)
            new_c[1] = last_avg_ref
            last_avg_ref = last_avg_ref

        # The last sum was to 0
        elsif(last_avg == 0)
            count_to_divise = cc[3].to_f
            if(count_to_divise == 0)
              new_c[1] = 0
            else
              new_c[1] = cc[2].to_f / count_to_divise
            end
            last_avg_ref = new_c[1]

        # If the sum and last sum is > 0
        else
            new_c[1] = ((sum_avg_ref.to_f + cc[2].to_f).to_f / (sum_count_ref.to_f + cc[3].to_f).to_f)
            last_avg_ref = new_c[1]
        end  

        # Set month and year  
        new_c[2] = cc[4]
        new_c[3] = cc[5]
        @charts_data[c[0]] << new_c
        
        # history for cumul    
        sum_avg       += cc[0].to_f
        sum_count     += cc[1].to_f
        sum_avg_ref   += cc[2].to_f
        sum_count_ref += cc[3].to_f
      end
    end
    if(@kpi_type_param == nil)
      render :generate_kpi_charts_data, :layout => false   
    else
      render :generate_kpi_charts_data
    end
  end

  # ------------------------------------------------------------------------------------
  # PRIVATE FUNCTIONS
  # ------------------------------------------------------------------------------------
  def kpi_prepare_parameters
    @lifecycles = Lifecycle.all.map {|u| [u.name,u.id]}    
    @milestones = MilestoneName.all.map {|u| [u.title,u.id]} 
    @milestones.insert(0,["None",0])

    @workstreams = Workstream.all.map {|u| [u.name,u.name]}
    @workstreams.insert(0,["None",0])

    @begin_date = "2013-01-01"
    @end_date   = DateTime.now.year.to_s+"-"+DateTime.now.month.to_s+"-"+DateTime.now.day.to_s

    @lifecycle_id       = params[:lifecycle_id]
    @workstream         = params[:workstream]
    @milestone_name_id  = params[:milestone_name_id]
    if (params[:begin_date])
      @begin_date  = params[:begin_date]
    end
    if (params[:end_date])
      @end_date  = params[:end_date]
    end
    
    # lifecycleMilestones = LifecycleMilestone.find(:all,:conditions => ["lifecycle_id = ?",@lifecycle_id])   
    #     @milestones = MilestoneName.find(:all,:conditions => ["id in (?)",lifecycleMilestones]).map {|u| [u.title,u.id]} 
    #     @milestones.insert(0,["None",0])
    
    # CHART TYPE --------------------------------- 
    @kpi_type = ""
    if (@kpi_type_param != nil)
      @kpi_type = @kpi_type_param
    else
      @kpi_type = params[:kpi_type]
    end
    
    @chart_type = ""
    if(@chart_type_param != nil)
      @chart_type = @chart_type_param
    else
      @chart_type = params[:chart_type]
    end
    
  end
  
  # Get all spiders which need to be used in KPI
  def get_spiders_consolidated(lifecycle,workstream,milestone,b_date,e_date)
    spiders_consolidated = Array.new
    
    spider_conso_query = "SELECT s.id,s.milestone_id FROM spiders s, spider_consolidations sc, milestones m, projects p, milestone_names as mn "
    spider_conso_query += " WHERE sc.spider_id = s.id"
    spider_conso_query += " AND s.milestone_id = m.id"
    spider_conso_query += " AND m.project_id = p.id"
    spider_conso_query += " AND m.name = mn.title"
    
    if ((lifecycle != nil) && (lifecycle != "0"))
      spider_conso_query += " AND p.lifecycle_id = '" + lifecycle.to_s + "'"
    end
    if ((workstream != nil) && (workstream != "0"))
      spider_conso_query += " AND p.workstream = '" + workstream + "'"
    end
    if ((milestone != nil) && (milestone != "0"))
      spider_conso_query += " AND mn.id = " + milestone
    end
    if ((b_date != nil) && (b_date != "0") && (e_date != nil) && (e_date != "0"))
      b_date_split = b_date.split("/")
      e_date_split = e_date.split("/")
      if (b_date_split.count == 3) and (e_date_split.count == 3)
        spider_conso_query += " AND YEAR(sc.created_at) BETWEEN "   + b_date_split[0] + " AND " + e_date_split[0]
        spider_conso_query += " AND MONTH(sc.created_at) BETWEEN "  + b_date_split[1] + " AND " + e_date_split[1]
      end
    end
    spider_conso_query += " AND s.created_at = (SELECT MAX(sbis.created_at) FROM spiders sbis WHERE id = s.id)"
    spider_conso_query += " GROUP BY s.milestone_id"
    
    ActiveRecord::Base.connection.execute(spider_conso_query).each do |spider|
      spiders_consolidated << spider[0].to_s
    end
    
    if spiders_consolidated.count == 0
      spiders_consolidated << 0
    end
    return spiders_consolidated
  end
  

 def helper_check_data_query(row,indexRow)
   if(row[indexRow] == nil)
     return ""
   else
     return row[indexRow]
   end
 end
 
end
