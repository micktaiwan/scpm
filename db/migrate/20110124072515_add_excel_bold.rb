require 'rubygems'
require 'differ'
Differ.format = :html

class AddExcelBold < ActiveRecord::Migration
  def self.up
    add_column :statuses, :last_change_excel, :text
    timestamps_off
    Project.all.each { |p|
      p.calculate_diffs
      }
    timestamps_on
  end

  def self.down
    remove_column :statuses, :last_change_excel
  end
  
  def self.timestamps_off
    Project.record_timestamps = false
    Status.record_timestamps  = false
    Action.record_timestamps  = false
    Request.record_timestamps = false
  end

  def self.timestamps_on
    Project.record_timestamps = true
    Status.record_timestamps  = true
    Action.record_timestamps  = true
    Request.record_timestamps = true
  end
  
end
