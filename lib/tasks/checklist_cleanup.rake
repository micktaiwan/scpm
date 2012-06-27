namespace :checklist do
  task :cleanup => :environment do
    ChecklistItem.cleanup
    ChecklistItemTemplate.all.each(&:deploy)
  end
end