class Chat < ActiveRecord::Migration
  def self.up
    add_column :people, :last_view, :datetime
    create_table :chat_sessions do |t|
      t.datetime :created_at
      t.string :title
    end
    create_table :chat_session_participants do |t|
      t.integer :chat_session_id
      t.integer :person_id
    end
    create_table :chat_messages do |t|
      t.integer :chat_session_id
      t.integer :person_id
      t.datetime :created_at
    end
    create_table :chat_message_reads do |t|
      t.integer :chat_message_id
      t.integer :person_id
    end
    
  end

  def self.down
    remove_column :people, :last_view
    drop_table :chat_sessions
    drop_table :chat_session_participants
    drop_table :chat_messages
    drop_table :chat_message_reads
  end
end
