require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test "new person" do
    p = Person.create(:name=>"test", :company_id=>1)  
    p.save!
    #assert p.company.name == 'Airbus'
  end
  
  test "find person" do
    p = Person.find_by_name("Delphine JOHAN")  
    assert p
    #assert p.company.name == 'Airbus'
  end
  
end
