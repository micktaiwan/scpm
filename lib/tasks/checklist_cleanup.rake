namespace :checklist do
  task :cleanup => :environment do
    ChecklistItem.all.select{|i| !i.good?}.each(&:destroy)
    ChecklistItemTemplate.all.each(&:deploy)
  end
end