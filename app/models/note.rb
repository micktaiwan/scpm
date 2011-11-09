class Note < ActiveRecord::Base

  belongs_to :person
  belongs_to :project
  belongs_to :capi_axis

  def css_class
    return case self.capi_axis_id
      when -1
      "note_box"
      else
      "note_box capi"
    end
  end

end

