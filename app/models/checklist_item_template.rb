class ChecklistItemTemplate < ActiveRecord::Base

  has_many :children, :class_name=>"ChecklistItemTemplate", :foreign_key=>"parent_id", :order=>"`order`", :dependent=>:nullify
  has_many :checklist_item_template_workpackages, :dependent=>:destroy
  has_many :workpackages, :through => :checklist_item_template_workpackages
  has_many :checklist_item_template_milestone_names, :dependent=>:destroy
  has_many :milestone_names, :through => :checklist_item_template_milestone_names
  belongs_to :parent, :class_name=>"ChecklistItemTemplate"#, :foreign_key=>"parent_id"

  def full_path
    return self.title if not self.parent or self.parent_id == 0
    self.parent.full_path + " > " + self.title
  end

  def has_ancestor?(id)
    return false if !self.parent
    return true if self.parent_id == id
    return self.parent.has_ancestor?(id)
  end

  # return all Requests fitting the template conditions
  def requests
    Request.find(:all, :conditions=>"resolution!='ended' and status='assigned'").select { |r|
      self.workpackages.map{|w| w.title}.include?(r.work_package)
      }
  end

  def find_or_deploy_parent(m, r)
    return nil if self.parent_id == 0 or !self.parent_id
    p = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent_id, r.id, m.id])
    return p if p
    self.parent.deploy
    return ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent_id, r.id, m.id])
  end

  def deploy
    self.requests.each { |r|
      r.milestones.select{|m1| self.milestone_names.map{|mn| mn.title}.include?(m1.name)}.each { |m|
        p = self.find_or_deploy_parent(m,r)
        parent_id = p ? p.id : 0
        i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id=?", self.id, m.id, r.id])
        if not i
          ChecklistItem.create(:milestone_id=>m.id, :request_id=>r.id, :parent_id=>parent_id, :template_id=>self.id)
        #else
          # if some milestone_names or workpackages have been added the new ChecklistItem will be created
          # TODO: detect removal of milestones or workpackages and delete not already answered ChecklistItem
          # for is_transverse: TODO: if changed from no to yes, a lto of cleanup must be done
          # for yes to no, the ChecklistItems will be created
        end        
        }
      }
  end

end

