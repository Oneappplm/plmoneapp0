namespace :hvhs do
	desc "Add HVHS Seed Data to Provider Source"
	task	:seed_data => :environment do
		Import::HvhsService.call(Rails.root.join('lib', 'data', 'hvhs.xlsx'))
	end
end