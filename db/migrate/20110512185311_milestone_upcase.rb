class MilestoneUpcase < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update milestones set name=UPPER(name)")
    ActiveRecord::Base.connection.execute("update milestones set name='Maintenance' where name='MAINT.'")
    ActiveRecord::Base.connection.execute("update milestones set name='Maintenance' where name='MAINTENANCE'")
    ActiveRecord::Base.connection.execute("update milestones set name='M10a' where name='M10A'")
    change_column :amendments, :milestone, :string
    ActiveRecord::Base.connection.execute("update amendments set milestone=UPPER(milestone)")
    ActiveRecord::Base.connection.execute("update amendments set milestone='M10a' where milestone='M10A'")
    add_column :projects, :pm_deputy, :string
    add_column :projects, :ispm, :string
  end

  def self.down
    #t.column  :milestone, "ENUM('m1','m3', 'm5', 'm7', 'm9', 'm10', 'm10a', 'm11', 'm12', 'm13', 'm14')"
    remove_column :projects, :pm_deputy
    remove_column :projects, :ispm
  end
end

