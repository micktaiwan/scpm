module ChatHelper
  def chat_get_people
    return [] if current_user == nil
    Person.find(:all, :conditions=>["is_supervisor=0 and last_view is not null and id!=?", chat_current_user.id], :order=>"name")
  end

  def chat_name(name)
    a = name.split(' ')
    if a.size > 0
      a[0]+' '+a[1][0].chr + '.'
    else
      name
    end
  end

  def chat_current_user
    current_user
  end

  def chat_find_participant(id)
    Person.find(id)
  end

  # find session with only this participant
  def chat_find_one_session(from_person_id, other_person_id)
    ChatSession.all.each { |s|
      p = s.participants
      #puts "#{s.id}: #{p.size}"
      next if p.size != 2
      return s if((p[0].person_id == from_person_id and p[1].person_id == other_person_id) or (p[1].person_id == from_person_id and p[0].person_id == other_person_id))
      }
    return nil
  end

end

