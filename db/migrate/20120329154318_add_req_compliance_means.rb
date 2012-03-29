class AddReqComplianceMeans < ActiveRecord::Migration
  def self.up
  	add_column :requirements, :compliance_means, :text
  	add_column :requirement_versions, :compliance_means, :text
  end

  def self.down
  	remove_column :requirements, :compliance_means
  	remove_column :requirement_versions, :compliance_means
  end
end
