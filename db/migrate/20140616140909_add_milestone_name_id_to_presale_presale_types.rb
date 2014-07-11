class AddMilestoneNameIdToPresalePresaleTypes < ActiveRecord::Migration
  def self.up
    add_column :presale_presale_types, :milestone_name_id, :integer
  end

  def self.down
    add_column :presale_presale_types, :milestone_name_id
  end
end
