class BetterReqs < ActiveRecord::Migration
  def self.up
    rename_column :requirements, :requirement, :short_name
    remove_column :requirements, :version
    remove_column :requirements, :version_date
    remove_column :requirements, :is_service_req
    remove_column :requirements, :source_date
    add_column    :requirements, :req_wave_id, :integer, :null=>false
    add_column    :requirements, :linked_req_id, :integer
    add_column    :requirements, :person_id, :integer
    Requirement.create_versioned_table
  end

  def self.down
    Requirement.drop_versioned_table
    rename_column :requirements, :short_name, :requirement
    #add_column    :requirements, :version, :integer
    add_column    :requirements, :version_date, :datetime
    add_column    :requirements, :source_date, :datetime
    add_column    :requirements, :is_service_req, :integer, :default=>0
    rename_column :requirements, :req_type, :is_service_req
    remove_column :requirements, :req_wave_id
    remove_column :requirements, :linked_req_id
    remove_column :requirements, :person_id
  end
end

