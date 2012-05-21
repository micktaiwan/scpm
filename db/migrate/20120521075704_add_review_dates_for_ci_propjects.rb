class AddReviewDatesForCiPropjects < ActiveRecord::Migration
  def self.up
  	add_column 		:ci_projects, :sqli_validation_date_review, :date
  	add_column 		:ci_projects, :airbus_validation_date_review, :date  
  	rename_column 	:ci_projects, :validation_date_objective, :sqli_validation_date_objective
  end

  def self.down
  	remove_column :ci_projects, :sqli_validation_date_review
  	remove_column :ci_projects, :airbus_validation_date_review
  	rename_column :ci_projects, :sqli_validation_date_objective, :validation_date_objective
  end
end
