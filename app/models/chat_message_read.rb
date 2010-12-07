class ChatMessageRead < ActiveRecord::Base
  belongs_to :chat_message
  belongs_to :person
  belongs_to :chat_session
end
