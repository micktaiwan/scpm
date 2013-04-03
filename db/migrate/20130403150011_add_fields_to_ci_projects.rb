class AddFieldsToCiProjects < ActiveRecord::Migration
  def self.up
    add_column :ci_projects, :deliverable_folder, :string
	  add_column :ci_projects, :ci_objectives_2013, :string
  	add_column :ci_projects, :sqli_validation_responsible, :string
	  add_column :ci_projects, :issue_history, :text
  end

  def self.down
    remove_column :ci_projects, :deliverable_folder
    remove_column :ci_projects, :ci_objectives_2013
    remove_column :ci_projects, :sqli_validation_responsible
    remove_column :ci_projects, :issue_history
  end
end
