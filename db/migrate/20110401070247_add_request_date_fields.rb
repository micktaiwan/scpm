class AddRequestDateFields < ActiveRecord::Migration
  def self.up
    add_column :requests, :status_to_be_validated,  :date
    add_column :requests, :status_new,              :date
    add_column :requests, :status_feedback,         :date
    add_column :requests, :status_acknowledged,     :date
    add_column :requests, :status_assigned,         :date
    add_column :requests, :status_contre_visite,    :date
    add_column :requests, :status_performed,        :date
    add_column :requests, :status_cancelled,        :date
    add_column :requests, :status_closed,           :date
    add_column :requests, :total_csv_severity,      :date
    add_column :requests, :total_csv_category,      :date
    add_column :requests, :po,                      :string
  end

  def self.down
    remove_column :requests, :status_to_be_validated
    remove_column :requests, :status_new
    remove_column :requests, :status_feedback
    remove_column :requests, :status_acknowledged
    remove_column :requests, :status_assigned
    remove_column :requests, :status_contre_visite
    remove_column :requests, :status_performed
    remove_column :requests, :status_cancelled
    remove_column :requests, :status_closed
    remove_column :requests, :total_csv_severity
    remove_column :requests, :total_csv_category
    remove_column :requests, :po
  end
end
