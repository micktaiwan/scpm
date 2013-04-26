class ChangeFieldsFromStream < ActiveRecord::Migration
  def self.up
    remove_column :streams, :total_qs_count
  	remove_column :streams, :total_spider_count

    # Mysql::Error: Duplicate column name 'read_date': ALTER TABLE `streams` ADD `read_date` datetime

  	#add_column :streams, :read_date, :datetime
  	#add_column :streams, :supervisor_id, :integer
  	#add_column :streams, :quality_manager, :string
  	#add_column :streams, :dwl, :string
  	#add_column :streams, :process_owner, :string
  end

  def self.down
    add_column :streams, :total_qs_count, :integer
  	add_column :streams, :total_spider_count, :integer
  	#remove_column :streams, :read_date
  	#remove_column :streams, :supervisor_id
  	#remove_column :streams, :quality_manager
  	#remove_column :streams, :dwl
  	#remove_column :streams, :process_owner
  end
end
