class CreateColumnSettings < ActiveRecord::Migration

  def self.up
		add_column :people, :settings, :text
		Person.all.each { |p|
			p.save_default_settings
		}
  end

  def self.down
  	remove_column :people, :settings
  end

end
