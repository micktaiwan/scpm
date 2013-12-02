class Milestone < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  belongs_to  :project
  has_many    :checklist_items, :dependent=>:destroy
  has_many    :spiders
  
  MILESTONE_ELIGIBLE_FOR_NOTE = ['M3', 'G2', 'M5', 'G5', 'QG TD', 'M13', 'CCB']
  MILESTONE_SPIDER_BLACKLIST  = ["M14", "G9", "sM14"]
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
    self.checklist_not_applicable==1 or self.done!=0 # self.status!=0
  end

  # Deploy checklist items from checklist templates
  def deploy_checklists

    # IS_QR_QWR
    if self.project.is_qr_qwr == true
      for t in ChecklistItemTemplate.find(:all, :conditions=>"is_qr_qwr=1").select{ |t|
          t.milestone_names.map{|n| n.title}.include?(self.name)
          }
        deploy_checklist_without_request(t)
      end
    end

    # WITH REQUEST
    if (self.active_requests.count > 0)
      return if checklist_not_allowed?

      self.project.active_requests.each { |r|
        next if !r.milestone_names or !r.milestone_names.include?(self.name)
        for t in ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0").select{ |t|
            t.milestone_names.map{|n| n.title}.include?(self.name) and
            (t.workpackages.map{|w| w.title}.include?(r.work_package)) and
            (r.contre_visite=="No" or r.contre_visite_milestone==self.name)
            }
          deploy_checklist(t,r)
        end
        }
    end

  end

  # Deploy checklist items from checklist template and for a specific request
  def deploy_checklist(template, request)
    p = template.find_or_deploy_parent(self,request)
    parent_id = p ? p.id : 0
    i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id=?", template.id, self.id, request.id])
    if not i
       ChecklistItem.create(:milestone_id=>self.id, :request_id=>request.id, :parent_id=>parent_id, :template_id=>template.id)
    else
      # parent change handling
      i.parent_id = parent_id
      i.save
      # if some milestone_names or workpackages have been added, the new ChecklistItem will be created
      # The detection of removal of milestones or workpackages must be done elsewhere
      # TODO is_transverse:
      # if changed from no to yes, a lot of cleanup must be done
      # for yes to no, the ChecklistItems will be created, cleanup the ProjectCheckItems
    end
  end

  # Deploy checklist items form checklist template but without request
  def deploy_checklist_without_request(template)
    p = template.find_or_deploy_parent_without_request(self)
    parent_id = p ? p.id : 0
    i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL", template.id, self.id])
    if not i
       ChecklistItem.create(:milestone_id=>self.id, :request_id=>nil, :parent_id=>parent_id, :template_id=>template.id)
    else
      # parent change handling
      i.parent_id = parent_id
      i.save
      # if some milestone_names or workpackages have been added, the new ChecklistItem will be created
      # The detection of removal of milestones or workpackages must be done elsewhere
      # TODO is_transverse:
      # if changed from no to yes, a lot of cleanup must be done
      # for yes to no, the ChecklistItems will be created, cleanup the ProjectCheckItems
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
    MILESTONE_ELIGIBLE_FOR_NOTE.include?(self.name)
  end

  def is_eligible_for_spider?
    return !MILESTONE_SPIDER_BLACKLIST.include?(self.name)
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
