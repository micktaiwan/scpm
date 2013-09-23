class PmTypeAxeExcel < ActiveRecord::Base
  belongs_to :pm_type_axe,  :foreign_key=>"axe_id"
  belongs_to :lifecycle,  :foreign_key=>"lifecycle_id"

end
