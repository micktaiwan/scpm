class AddFirstLogin < ActiveRecord::Migration
  def self.up
    u = Person.find_by_rmt_user('mfaivremacon')
    u.login = 'mick'
    u.pwd   = '8a0d6b88bc3deb13702cee6f335b0547b1d9f0fb'
    u.save
  end

  def self.down
  end
end

