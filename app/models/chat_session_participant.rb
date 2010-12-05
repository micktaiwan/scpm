class ChatSessionParticipant < ActiveRecord::Base

  belongs_to :chat_session
  belongs_to :person

end
