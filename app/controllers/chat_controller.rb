class ChatController < ApplicationController

  include ChatHelper

  def refresh
    @people = chat_get_people
    render(:partial=>'chat/person', :collection=>@people)
  end

  def find_session_with
    person_id = params[:id]
    s = chat_find_one_session(chat_current_user.id, person_id.to_i)
    if s
      render(:text=>s.id)
    else
      render(:text=>"")
    end
  end

  def refresh_sessions
    # get all unread messages
    msg_read = ChatMessageRead.find(:all, :conditions=>["person_id=?", chat_current_user.id])
    render(:text=>"") and return if msg_read.size == 0
    # get unique session ids
    sessions = []
    msg_read.map{|r| r.chat_message.chat_session_id}.uniq.each { |id|
      s = ChatSession.find(id)
      sessions << render_to_string(:partial=>"chat_window", :locals=>{:s=>s})
      #render_to_string(:partial=>"message_collection", :locals=>{:s=>s})
      }
    msg_read.each { |r| r.state = 1; r.save }
    render(:text=>sessions.join('||sessions||'))
  end

  def set_read
    session_id = params[:session_id]
    person_id = params[:person_id]
    ChatSession.find(session_id).set_all_messages_read(person_id)
    render(:nothing=>true)
  end

  def create_new_session
    person_id = params[:id]
    s = chat_find_one_session(chat_current_user.id, person_id.to_i)
    if not s
      s = ChatSession.create(:title=>Date.today())
      s.participants << ChatSessionParticipant.create(:chat_session_id=>s.id, :person_id=>chat_current_user.id)
      s.participants << ChatSessionParticipant.create(:chat_session_id=>s.id, :person_id=>person_id)
    end
    render(:partial=>"chat_window", :locals=>{:s=>s})
  end

  def send_chat_msg
    session_id = params[:id].to_i
    msg        = params[:msg]
    s = ChatSession.find(session_id)
    s.send_msg(chat_current_user.id, msg)
    render(:nothing=>true)
  end

end


