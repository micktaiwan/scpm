require 'test_helper'

class ChecklistItemTemplateTest < ActiveSupport::TestCase

  test "basic checks" do
    assert checklist_item_templates(:dn).workpackages.include?(workpackages(:assurance))
    assert checklist_item_templates(:dn).milestone_names.include?(milestone_names(:m5))
    assert checklist_item_templates(:dn).milestone_names.map{|mn| mn.title}.include?('M5')
    assert checklist_item_templates(:dn).requests.include?(requests(:request))
    assert checklist_item_templates(:pp).requests.include?(requests(:request))
  end

  test "deployment test" do
    checklist_item_templates(:dn).deploy
    checklist_item_templates(:pp).deploy
    assert milestones(:milestone).checklist_items.size == 2
    assert milestones(:milestone).checklist_items.second.parent == milestones(:milestone).checklist_items.first
  end

  test "template modification and redeployment" do
    checklist_item_templates(:dn).deploy
    checklist_item_templates(:pp).deploy
    assert milestones(:milestone).checklist_items.second.parent == milestones(:milestone).checklist_items.first
    checklist_item_templates(:pp).parent_id = 0
    checklist_item_templates(:pp).deploy
    assert milestones(:milestone).checklist_items.size == 2
    assert milestones(:milestone).checklist_items.second.parent_id == 0
  end

end

