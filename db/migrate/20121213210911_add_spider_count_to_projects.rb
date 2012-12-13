class AddSpiderCountToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :spider_count, :integer, :default=> 0
  end

  def self.down
  	remove_column :projects, :spider_count
  end
end
