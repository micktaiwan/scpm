class CreatePresaleIgnoreProjects < ActiveRecord::Migration
  def self.up
    create_table :presale_ignore_projects do |t|
    	t.integer :project_id
    	t.integer :presale_type_id
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_ignore_projects
  end
end
