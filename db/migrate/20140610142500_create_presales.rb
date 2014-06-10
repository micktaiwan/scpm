class CreatePresales < ActiveRecord::Migration
  def self.up
    create_table :presales do |t|
    	t.integer :project_id
      	t.timestamps
    end
  end

  def self.down
    drop_table :presales
  end
end
