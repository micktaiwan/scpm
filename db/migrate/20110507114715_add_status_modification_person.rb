class AddStatusModificationPerson < ActiveRecord::Migration
  def self.up
    add_column :statuses, :last_modifier, :integer
    add_column :statuses, :locked,        :integer, :default=>0
    add_column :statuses, :locked_time,   :datetime
    add_column :people,   :sdp_id,        :integer, :default=>-1
    add_column :projects, :lifecycle,     :integer, :default=>0
    add_column :actions,  :origin_id,     :integer, :default=>0
  end

  def self.down
    remove_column :statuses,  :last_modifier
    remove_column :people,    :sdp_id
    remove_column :projects,  :lifecycle
    remove_column :statuses,  :locked
    remove_column :statuses,  :locked_time
    remove_column :actions,   :origin_id
  end
end

