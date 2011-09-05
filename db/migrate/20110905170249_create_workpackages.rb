class CreateWorkpackages < ActiveRecord::Migration
  def self.up
    create_table :workpackages do |t|
      t.string :title
      t.string :shortname
      t.string :code
    end
    for t, s, c in [
      ["WP1.2 - Quality Assurance", "Assurance", "1.2"],
      ["WP1.2 - Quality AssuranceCV","Assurance CV", "1.2CV"],
      ["WP1.1 - Quality Control","Control", "1.1"],
      ["WP1.1 - Quality ControlCV","Control CV", "1.1CV"],
      ["WP1.4 - Quality Assurance + BAT","Assurance+BAT", "1.4"],
      ["WP1.3 - Quality Control + BAT","Control+BAT", "1.3"],
      ["WP2 - Quality for Maintenance","Maintenance", "2"],
      ["WP3.0 - Old Modeling","Old Modelling", "3.0"],
      ["WP3.1 - Modeling Support","Mod Support", "3.1"],
      ["WP3.2 - Modeling Conception and Production","Modeling Prod", "3.2"],
      ["WP3.3 - Modeling BAT specific Control","BAT Mod Control", "3.3"],
      ["WP3.4 - Modeling BAT specific Production","BAT Mod Prod", "3.4"],
      ["WP4.1 - Surveillance Audit","Audit", "4.1"],
      ["WP4.2 - Surveillance Root cause","RCA", "4.2"],
      ["WP5 - Change Accompaniment","Change", "5"],
      ["WP6.1 - Coaching PP","Coaching PP", "6.1"],
      ["WP6.2 - Coaching BRD","Coaching BRD", "6.2"],
      ["WP6.3 - Coaching V&V","Coaching V&V", "6.3"],
      ["WP6.4 - Coaching ConfMgt","Coaching ConfMgt", "6.4"],
      ["WP6.5 - Coaching Maintenance", "Coaching Maint.", "6.5"]
      ]
      Workpackage.create(:title=>t, :shortname=>s, :code=>c)
    end
  end

  def self.down
    drop_table :workpackages
  end
end

