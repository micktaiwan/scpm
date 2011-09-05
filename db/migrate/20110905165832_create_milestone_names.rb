class CreateMilestoneNames < ActiveRecord::Migration
  def self.up
    create_table :milestone_names do |t|
      t.string :title
    end
    for t in ['M1','M3','QG BRD','QG ARD','M5','M5/M7','M7','M9','M9/M10','M10','QG TD','M10a','QG MIP','M11','M12','M12/M13','M13','M14','CCB','QG TD M','MIPM','G0','G2','G3','G4','G5','G6','G7','G8','G9','g0','g2','g3','g4','g5','g6','g7','g8','g9','pg0','pg2','pg3','pg4','pg5','pg6','pg7','pg8','pg9','sM1','sM3','sM5','sM13','sM14']
      MilestoneName.create(:title=>t)
    end  end

  def self.down
    drop_table :milestone_names
  end
end

