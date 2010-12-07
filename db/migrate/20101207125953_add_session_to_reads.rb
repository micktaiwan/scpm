class AddSessionToReads < ActiveRecord::Migration
  def self.up
    add_column :chat_message_reads, :chat_session_id, :integer
    ChatMessageRead.all.each { |r|
      if r.chat_session_id == nil
        r.chat_session_id = r.chat_message.chat_session_id
        r.save
      end
      }
  end

  def self.down
    remove_column :chat_message_reads, :chat_session_id
  end
end
