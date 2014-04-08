class UpdateMonthlyTaskTypesTemplates < ActiveRecord::Migration
  def self.up
  	MonthlyTaskType.create(:name => "Resp", :template => '[NAME];0;0;[LOAD];32329;142239;110;;-1;-1;3989;-1;-1;-1;13;[LOGIN];[PROFIL];0;31245;[DATE];0;1;"Internal SQLI Meetings (imported from BAM)";;;1;fintask')
  	MonthlyTaskType.create(:name => "QR", :template => '[NAME];0;0;[LOAD];32329;142239;110;;-1;-1;3989;-1;-1;-1;13;[LOGIN];[PROFIL];0;31245;[DATE];0;1;"Internal SQLI Meetings (imported from BAM)";;;1;fintask')
  	MonthlyTaskType.create(:name => "CPDP", :template => '[NAME];0;0;[LOAD];32329;142237;112;;-1;-1;3989;-1;-1;-1;13;[LOGIN];[PROFIL];0;31245;[DATE];0;1;"Internal SQLI Meetings (imported from BAM)";;;1;fintask')

  end

  def self.down
  end
end
