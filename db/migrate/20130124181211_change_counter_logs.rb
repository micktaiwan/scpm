class ChangeCounterLogs < ActiveRecord::Migration
  def self.up
    remove_column :counter_logs, :project_id
    remove_column :counter_logs, :stream_id
    remove_column :counter_logs, :credit
    remove_column :counter_logs, :debit
    add_column :counter_logs, :request_id, :integer
  	add_column :counter_logs, :counter_value, :integer
  	add_column :counter_logs, :import_date, :datetime
  	add_column :counter_logs, :validity, :boolean, :default=>0
  end

  def self.down
    remove_column :counter_logs, :request_id
    remove_column :counter_logs, :counter_value
    remove_column :counter_logs, :import_date
    remove_column :counter_logs, :validity
    add_column :counter_logs, :project_id, :integer
  	add_column :counter_logs, :stream_id, :integer
  	add_column :counter_logs, :credit, :integer
  	add_column :counter_logs, :debit, :integer
  end
end