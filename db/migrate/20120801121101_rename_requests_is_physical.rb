class RenameRequestsIsPhysical < ActiveRecord::Migration
    def self.up
      rename_column :requests, :is_physical, :request_type
    end

    def self.down
      rename_column :requests, :request_type, :is_physical
    end
  end
