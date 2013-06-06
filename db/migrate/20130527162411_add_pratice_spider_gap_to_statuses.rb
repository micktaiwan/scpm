class AddPraticeSpiderGapToStatuses < ActiveRecord::Migration
  def self.up
  	add_column :statuses, :pratice_spider_gap, :text
  end

  def self.down
  	remove_column :statuses, :pratice_spider_gap
  end
end
