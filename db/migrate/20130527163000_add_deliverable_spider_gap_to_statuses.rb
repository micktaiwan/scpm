class AddDeliverableSpiderGapToStatuses < ActiveRecord::Migration
  def self.up
  	add_column :statuses, :deliverable_spider_gap, :text
  end

  def self.down
  	remove_column :statuses, :deliverable_spider_gap
  end
end
