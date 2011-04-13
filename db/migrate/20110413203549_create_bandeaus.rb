class CreateBandeaus < ActiveRecord::Migration
  def self.up
    create_table :bandeaus do |t|
      t.text        :text
      t.integer     :person_id
      t.datetime    :last_display
      t.integer     :nb_displays, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :bandeaus
  end
end

