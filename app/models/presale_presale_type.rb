class PresalePresaleType < ActiveRecord::Base
  	belongs_to  :presale
  	belongs_to  :presale_type
  	belongs_to	:milestone_name
  	has_many	:presale_comments, :order=>"presale_comments.created_at DESC"

  	def getLastComment()
  		comments = presale_comments(:first,:order=>"creation_date")
  		if comments.count > 0
  			return comments[0]
  		end
  		return nil
  	end
end
