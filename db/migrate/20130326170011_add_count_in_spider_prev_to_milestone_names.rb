class AddCountInSpiderPrevToMilestoneNames < ActiveRecord::Migration
  def self.up
  add_column :milestone_names, :count_in_spider_prev, :boolean, :default=> 1
  end

  def self.down
    remove_column :milestone_names, :count_in_spider_prev
  end
end
