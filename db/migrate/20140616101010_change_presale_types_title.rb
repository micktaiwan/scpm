class ChangePresaleTypesTitle < ActiveRecord::Migration
	def self.up
		change_column :presale_types, :title, :text
	end

	def self.down
		change_column :presale_types, :title, :integer
	end
end

