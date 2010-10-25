class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end
    create_table :person_roles do |t|
      t.column :person_id, :integer
      t.column :role_id, :integer
      t.column :created_at, :datetime
    end
    add_index :roles, :name
    Role.create(:name => 'Admin')
    Role.create(:name => 'Super')
    Role.create(:name => 'QR')
    Role.create(:name => 'Viewer')
  end

  def self.down
    drop_table :roles
    drop_table :person_roles
  end
end

