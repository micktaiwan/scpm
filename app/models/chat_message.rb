class ChatMessage < ActiveRecord::Base
  belongs_to :person
  belongs_to :chat_session
  has_many :chat_message_reads, :dependent => :destroy
end

