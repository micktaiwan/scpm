class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string  :controller
      t.string  :action
      t.string  :controller_action
      t.string  :browser
      t.string  :ip
      t.string  :session_id
      t.integer :user_id
      t.text    :params
      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
