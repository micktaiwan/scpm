class AddEvolutionFields < ActiveRecord::Migration
  def self.up
    add_column :statuses, :reason, :text
    add_column :statuses, :operational_alert, :text
  end

  def self.down
    remove_column :statuses, :reason
    remove_column :statuses, :operational_alert
  end
end
