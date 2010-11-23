module ChatHelper
  def chat_get_people
    Person.find(:all, :conditions=>"is_supervisor=0", :order=>"name")
  end

  def chat_name(name)
    a = name.split(' ')
    if a.size > 0
      a[0]+' '+a[1][0].chr + '.'
    else
      name
    end
  end

end

