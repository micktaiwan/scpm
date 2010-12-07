class ChatSession < ActiveRecord::Base

  has_many :participants, :class_name=>"ChatSessionParticipant", :dependent => :destroy
  has_many :messages, :class_name=>"ChatMessage", :order=>"created_at", :dependent => :destroy
  has_many :chat_message_reads
  
  include ChatHelper

  def send_msg(from_id, msg)
    msg = ChatMessage.create(:chat_session_id=>self.id, :person_id=>from_id, :msg=>msg)
    self.participants.each { |p|
      ChatMessageRead.create(:chat_message_id=>msg.id, :person_id=>p.person_id, :chat_session_id=>self.id) if p.person_id != from_id
      }
  end
  
  def set_all_messages_read(person_id)
    ChatMessageRead.find(:all, :conditions=>["chat_session_id=? and person_id=?", self.id, person_id]).each { |r|
      r.destroy
      }
  end  
 
end
