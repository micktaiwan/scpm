class CreateWlLineTasks < ActiveRecord::Migration
	def self.up
		create_table :wl_line_tasks do |t|
			t.integer :wl_line_id
			t.integer :sdp_task_id
		end
	end

	def self.down
		drop_table :wl_line_tasks
	end
end
