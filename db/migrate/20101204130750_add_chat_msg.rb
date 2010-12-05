class AddChatMsg < ActiveRecord::Migration
  def self.up
    add_column :chat_messages, :msg, :text
  end

  def self.down
    remove_column :chat_messages, :msg
  end
end

