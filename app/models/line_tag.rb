class LineTag < ActiveRecord::Base

def tag_name
	tag = Tag.find(self.tag_id)
	return tag.name
end

end
