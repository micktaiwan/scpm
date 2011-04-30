class AddFirstLogin < ActiveRecord::Migration
  def self.up
    u = Person.find_by_rmt_user('mfaivremacon')
    if not u
      u = Person.create(:rmt_user=>"mfaivremacon", :name=>'Mickael')
    end
    u.login = 'mfaivremacon'
    u.pwd   = '8a0d6b88bc3deb13702cee6f335b0547b1d9f0fb' # useless as LDAP is used
    u.add_role('Super') # super admin
    u.add_role('Admin')
    u.add_role('QR')
    #u.add_role('Viewer')
    u.save
  end

  def self.down
  end
end

