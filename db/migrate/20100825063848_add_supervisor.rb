class AddSupervisor < ActiveRecord::Migration
  def self.up
    add_column :projects, :supervisor_id, :integer
    add_column :people, :is_supervisor, :integer, :default=>0
  end

  def self.down
    remove_column :projects, :supervisor_id
    remove_column :people, :is_supervisor
  end
end
