class RenameSdpPhasesByTypeIsPhysical < ActiveRecord::Migration
    def self.up
      rename_column :sdp_phases_by_type, :isPhysical, :request_type
    end

    def self.down
      rename_column :sdp_phases_by_type, :request_type, :isPhysical
    end
  end
