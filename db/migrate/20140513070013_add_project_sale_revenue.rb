class AddProjectSaleRevenue < ActiveRecord::Migration
  def self.up
  	add_column :projects, :sales_revenue, :integer, :default=>0
  end

  def self.down
  	remove_column :projects, :sales_revenue
  end
end
