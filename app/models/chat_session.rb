class ChatSession < ActiveRecord::Base

  has_many :participants, :class_name=>"ChatSessionParticipant", :dependent => :destroy
  has_many :messages, :class_name=>"ChatMessage", :order=>"created_at", :dependent => :destroy
  include ChatHelper

  def send_msg(from_id, msg)
    msg = ChatMessage.create(:chat_session_id=>self.id, :person_id=>from_id, :msg=>msg)
    self.participants.each { |p|
      ChatMessageRead.create(:chat_message_id=>msg.id, :person_id=>p.person_id) # if p.person_id != from_id
      }
  end

end

