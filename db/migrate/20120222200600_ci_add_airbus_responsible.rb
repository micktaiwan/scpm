class CiAddAirbusResponsible < ActiveRecord::Migration
  def self.up
  	add_column :ci_projects, :airbus_responsible, :string
  end

  def self.down
  	remove_column :ci_projects, :airbus_responsible
  end
end
