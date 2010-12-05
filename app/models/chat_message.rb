class ChatMessage < ActiveRecord::Base
  belongs_to :person
  belongs_to :chat_session
end

