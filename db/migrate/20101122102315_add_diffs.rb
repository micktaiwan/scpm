require 'rubygems'
require 'differ'
Differ.format = :html

class AddDiffs < ActiveRecord::Migration
  def self.up
    add_column :statuses, :explanation_diffs, :text
    add_column :statuses, :last_change_diffs, :text
    Project.all.each { |p|
      p.calculate_diffs
      }
  end

  def self.down
    remove_column :statuses, :explanation_diffs
    remove_column :statuses, :last_change_diffs
  end
end
