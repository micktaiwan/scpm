require 'test_helper'

class ChecklistItemTest < ActiveSupport::TestCase

  test "milestone request" do
    checklist_item_templates(:dn).workpackages.include?(workpackages(:assurance))
    checklist_item_templates(:dn).milestone_names.include?(milestone_names(:m5))
    assert checklist_item_templates(:dn).requests.include?(requests(:request))
    #assert checklist_item_templates(:pp).requests.include?(requests(:request))
  end

  test "deployment test" do
    checklist_item_templates(:dn).deploy
    assert milestones(:milestone).checklist_items.size > 0
  end
end
