class AddPhaseByTypeIdToSdpTasks < ActiveRecord::Migration
  def self.up
    add_column :sdp_tasks, :phase_by_type_id, :integer
  end

  def self.down
    remove_column :sdp_tasks, :phase_by_type_id
  end
end
