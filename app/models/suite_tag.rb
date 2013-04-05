class SuiteTag < ActiveRecord::Base
  has_many    :projects, :dependent=>:nullify
end
