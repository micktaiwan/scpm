class AddDateToReqs < ActiveRecord::Migration
  def self.up
    add_column :requirements, :source_date, :date
    add_column :requirements, :source_identifier, :string
    add_column :requirements, :priority, :integer
    add_column :requirements, :impact, :integer
    add_column :requirement_versions, :impact, :integer
    add_column :requirement_versions, :source_date, :date
    add_column :requirement_versions, :source_identifier, :string
    add_column :requirement_versions, :priority, :integer
    add_column :req_waves, :deployment_target_date, :date
    add_column :req_waves, :deployment_target_date_revision, :date
  end

  def self.down
    remove_column :requirements, :source_date
    remove_column :requirements, :source_identifier
    remove_column :requirements, :priority
    remove_column :requirements, :impact
    remove_column :requirement_versions, :impact
    remove_column :requirement_versions, :source_date
    remove_column :requirement_versions, :source_identifier
    remove_column :requirement_versions, :priority
    remove_column :req_waves, :deployment_target_date
    remove_column :req_waves, :deployment_target_date_revision
  end
end

