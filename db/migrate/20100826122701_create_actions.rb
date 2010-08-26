class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.string    :action
      t.user      :user_id # responsible
      t.integer   :project_id # workpackage
      t.date      :creation_date
      t.date      :due_date
      t.column    :progress, "ENUM('open', 'in_progress', 'closed', 'abandonned')"
      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
