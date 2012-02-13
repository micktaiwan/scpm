class CreateCiProjects < ActiveRecord::Migration
  def self.up
    create_table :ci_projects do |t|
      t.integer :internal_id
      t.integer :external_id
      t.string :stage
      t.string :category
      t.string :severity
      t.text :summary
      t.text :description
      t.string :status
      t.datetime :submission_date
      t.string :reporter
      t.datetime :last_update
      t.string :last_update_person
      t.string :assigned_to
      t.string :priority
      t.string :visibility
      t.float :resolution_charge
      t.text :additional_information
      t.date :taking_into_account_date
      t.date :realisaton_date
      t.string :realisation_author
      t.date :delivery_date
      t.string :origin
      t.string :improvement_target_objective
      t.string :scope_l2
      t.text :deliverable_list
      t.string :accountable
      t.string :deployment
      t.date :launching_date
      t.date :validation_date_objective
      t.date :airbus_validation_date_objective
      t.date :deployment_date_objective
      t.date :sali_validation_date
      t.date :airbus_validation_date
      t.date :deployment_date
      t.date :deployment_date_review
      t.timestamps
    end
  end

  def self.down
    drop_table :ci_projects
  end
end
