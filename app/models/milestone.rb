class Milestone < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  belongs_to  :project
  has_many    :checklist_items, :dependent=>:destroy
  has_many    :spiders
  
  def date
    return self.actual_milestone_date if self.actual_milestone_date and self.actual_milestone_date!=""
    self.milestone_date
  end

  def to_s
    name
  end

  def passed_style
    return " passed" if (done > 0 or status == -1) && !project.is_qr_qwr
    return ""
  end

  def timealert
    return "passed"  if done == 1
    return "skipped" if done == 2
    d = date
    if d.blank?
      return "missing" if status != -1
      return "blank"
    end
    diff = d - Date.today
    return "verysoon" if diff <= 5
    return "soon" if diff <= 10
    return "normal"
  end

  def requests
    rv = []
    self.project.requests.each { |r|
      rv << r if r.milestone_names and r.milestone_names.include?(self.name)
      }
    rv
  end

  def active_requests
    rv = []
    self.project.active_requests.each { |r|
      rv << r if r.milestone_names and r.milestone_names.include?(self.name)
      }
    rv
  end

  def amendments
    self.project.amendments.select{|a| a.milestone == self.name}
  end

  def checklist_not_allowed?
    if checklist_to_deploy? or checklist_to_delete?
      return true
    end
    return false
  end

  def checklist_to_deploy?
     self.done==0
  end

  def checklist_to_delete?
    self.checklist_not_applicable==1
  end

  # Deploy checklist items from checklist templates
  def deploy_checklists

    # If ths milestone shouldn't have anymore some checklists. We delete the checklist items which are not already be used
    if checklist_to_delete?
      ChecklistItem.find(:all, :conditions=>["parent_id != 0 and status = 0 and milestone_id=? and project_id IS NULL", self.id]).each(&:destroy)
      return
    end
    if checklist_to_deploy?
      return
    end

    # IS_QR_QWR 
    if self.project.is_qr_qwr == true
      # Parents
      for t in ChecklistItemTemplate.find(:all, :conditions=>"is_qr_qwr=1 and parent_id = 0").select{ |t|
          t.milestone_names.map{|n| n.title}.include?(self.name)
          }
            # Deploy parent is qr qwr
            i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", t.id, self.id])
            if i == nil
              ChecklistItem.create(:milestone_id=>self.id, :parent_id=>0, :template_id=>t.id)
            end
      end

      # Childs
      for t in ChecklistItemTemplate.find(:all, :conditions=>"is_qr_qwr=1 and parent_id != 0").select{ |t|
          t.milestone_names.map{|n| n.title}.include?(self.name)
          }
            # Deploy child is qr qwr
            i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", t.id, self.id])
            # Create
            if i == nil
              # Get the parent
              parent = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", t.parent.id, self.id])
              if parent
                ChecklistItem.create(:milestone_id=>self.id, :parent_id=>parent.id, :template_id=>t.id)
              end
            # Update
            else
              # Get the parent
              parent = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", t.parent.id, self.id])
              if parent
                i.parent_id = parent.id
                i.save
              end
            end
      end
    end

    # WITH REQUEST
    if (self.active_requests.count > 0)

      # Parents
      self.project.active_requests.each { |r|
        next if !r.milestone_names or !r.milestone_names.include?(self.name)
        for t in ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0 and parent_id = 0").select{ |t|
            t.milestone_names.map{|n| n.title}.include?(self.name) and
            (t.workpackages.map{|w| w.title}.include?(r.work_package)) and
            (r.contre_visite=="No" or r.contre_visite_milestone==self.name)
            }
            # Deploy parent request
            p = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", t.id, r.id, self.id])
            if p == nil
              ChecklistItem.create(:milestone_id=>self.id, :request_id=>r.id, :parent_id=>0, :template_id=>t.id)
            end
        end
        }

      # Childs
      self.project.active_requests.each { |r|
        next if !r.milestone_names or !r.milestone_names.include?(self.name)
        for t in ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0 and parent_id != 0").select{ |t|
            t.milestone_names.map{|n| n.title}.include?(self.name) and
            (t.workpackages.map{|w| w.title}.include?(r.work_package)) and
            (r.contre_visite=="No" or r.contre_visite_milestone==self.name)
            }

              # Deploy child request
              c = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", t.id, r.id, self.id])
              # Create
              if c == nil
                parent = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", t.parent.id, r.id, self.id])
                if parent
                  ChecklistItem.create(:milestone_id=>self.id, :request_id=>r.id, :parent_id=>parent.id, :template_id=>t.id)
                end
              # Update
              else
                parent = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", t.parent.id, r.id, self.id])
                if parent
                  c.parent_id = parent.id
                  c.save
                end
              end
        end
        }

    end

  end

  def destroy_checklist
    ChecklistItem.destroy_all(["milestone_id=?", self.id])
  end

  def shortnames(rs)
    rs.map{|r| r.shortname}.join("\n")
  end

  def check
    rs = self.requests.select{|r| r.status=="assigned"}
    # check status
    if self.status == -1
      self.update_attribute('status',0) if rs.size > 0
    elsif self.status == 0
      self.update_attribute('status',-1) if rs.size == 0
    end
    self.update_attribute('comments', self.comments.gsub("No request",shortnames(rs))) if rs.size > 0 and self.comments

    # check done
    self.update_attribute('done',1) if self.status == 1 and self.done == 0

    # deploy checklists
    self.deploy_checklists
  end


  # Show the numer of checklist for cu (one user) and the current milestone
  def checklist_div(cu)
    items     = self.checklist_items.select{|i| i.ctemplate.ctype!='folder'}

    return "" if items.size == 0 and !cu.has_role?('Admin')
    non_zero  = items.select{|i| i.status!=0}
    modif = ""
    if non_zero.size==items.size
      modif = " done"
    elsif self.checklist_items.select{|i| i.late?}.size > 0
      modif = " alert"
    end
    css_class = "milestone_cl#{modif}"
    "<div class='#{css_class}' onclick='open_checklist(#{self.id})'>Checks: #{non_zero.size}/#{items.size}</div>"
  end

  def delay_in_words
    begin
    return "" if !self.milestone_date or self.milestone_date=="" or
                 !self.actual_milestone_date or self.actual_milestone_date=="" or
                 self.actual_milestone_date <= self.milestone_date
    time_ago_in_words(Time.now-(self.actual_milestone_date-self.milestone_date).to_i.days) + " delay"
    rescue Exception => e
      return "#{e}"
    end
  end

  def is_eligible_for_note?
    APP_CONFIG['report_milestones_eligible_for_note'].include?(self.name)
  end

  def is_eligible_for_spider?
    return !APP_CONFIG['report_spider_milestone_blacklist'].include?(self.name)
  end

  def has_spider_no_consolidated?
    result = false
    self.spiders.each do |s|
      if !s.is_consolidated?
        result = true
      end
    end
    return result;
  end

end
