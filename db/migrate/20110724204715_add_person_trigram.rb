class AddPersonTrigram < ActiveRecord::Migration
  def self.up
    add_column :people, :trigram, :string
  end

  def self.down
    remove_column :people, :trigram
  end
end
