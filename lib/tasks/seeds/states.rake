namespace :states do
	desc "Add states seed data"
	task :seed_data => :environment do
		Import::StatesService.call(Rails.root.join('lib', 'data', 'states.xlsx'))
	end
end
