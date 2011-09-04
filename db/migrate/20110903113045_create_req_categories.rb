class CreateReqCategories < ActiveRecord::Migration
  def self.up
    create_table :req_categories do |t|
      t.integer :parent_id
      t.integer :public, :default=>0
      t.string  :label
      t.timestamps
    end
  end

  def self.down
    drop_table :req_categories
  end
end
