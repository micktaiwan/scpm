# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Person.destroy_all
Company.destroy_all
# Project.destroy_all

companies = []
companies << [{ :name => 'Airbus'}]
companies << [{ :name => 'SQLI'}]
Company.create(companies)

airbus = Company.find_by_name('Airbus')

persons = []
persons << [{ :name => 'Catherine POTTIER', :email=>'catherine.pottier@airbus.com', :company_id=>airbus.id}]
persons << [{ :name => 'Delphine JOHAN',    :email=>'delphine.johan@airbus.com',    :company_id=>airbus.id}]
Person.create(persons)

