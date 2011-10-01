module WorkloadsHelper

  def short_name(name)
    a = name.split(' ')
    if a.size > 0
      a[0]+' '+a[1][0].chr + '.'
    else
      name
    end
  end

end
