class CreateWorkstreams < ActiveRecord::Migration
  def self.up
    create_table :workstreams do |t|
      t.integer :supervisor_id
      t.string :name
      t.text :strenghts
      t.text :weaknesses
      t.timestamps
    end
    
    ['EA', 'EI', 'EV', 'EDE', 'EDG', 'EDS', 'EDY', 'EDC', 'EM', 'EMNB', 'EMNC'].each { |name|
      Workstream.create(:name => name)
      }
  end

  def self.down
    drop_table :workstreams
  end
end
