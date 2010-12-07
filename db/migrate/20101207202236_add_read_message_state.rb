class AddReadMessageState < ActiveRecord::Migration
  def self.up
    add_column :chat_message_reads, :state, :integer, :default=>0 # 0: unsent to client, 1: message has been displayed
  end

  def self.down
    remove_column :chat_message_reads, :state
  end
end
