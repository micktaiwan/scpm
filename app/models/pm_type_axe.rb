class PmTypeAxe < ActiveRecord::Base
  belongs_to :pm_type
  has_many :lifecycle_questions, :dependent=>:nullify
  has_many :spider_consolidations, :dependent=>:nullify


def self.get_sorted_axes
	return PmTypeAxe.find(:all).sort_by{ |a| [a.pm_type_id, a.title] }
end

end
