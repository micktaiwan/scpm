class CreateRequirements < ActiveRecord::Migration
  def self.up
    create_table :requirements do |t|
      t.integer   :req_category_id
      t.string    :source_name
      t.date      :source_date
      t.string    :requirement
      t.text      :description
      t.integer   :version
      t.datetime  :version_date
      t.integer   :status
      t.datetime  :status_date
      t.integer   :is_service_req, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :requirements
  end
end
