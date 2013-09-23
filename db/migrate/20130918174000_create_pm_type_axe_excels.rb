class CreatePmTypeAxeExcels < ActiveRecord::Migration
  def self.up
    create_table :pm_type_axe_excels do |t|
    	t.integer :axe_id
    	t.integer :lifecycle_id
      t.integer :excel_position
		t.timestamps
    end
  end

  def self.down
    drop_table :pm_type_axe_excels
  end
end
