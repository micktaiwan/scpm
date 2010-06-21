class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :request_id
      t.string :workstream
      t.string :status
      t.string :assigned_to
      t.string :resolution
      t.string :updated
      t.string :reporter
      t.string :view_status
      t.string :milestone
      t.string :priority
      t.string :summary
      t.string :date_submitted
      t.string :product_version
      t.string :severity
      t.string :platform
      t.string :work_package
      t.string :complexity
      t.string :start_date
      t.timestamps
    end
    
    add_index :requests, :request_id
    
  end

  def self.down
    drop_table :requests
  end
end

