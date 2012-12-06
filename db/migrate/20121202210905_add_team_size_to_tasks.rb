class AddTeamSizeToTasks < ActiveRecord::Migration
  def self.up
  	add_column :tasks, :team_size, :float, :default=>0.0
  end

  def self.down
  	remove_column :tasks, :team_size
  end
end
