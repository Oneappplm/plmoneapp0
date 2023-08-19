namespace :board_names do
	desc "Add board_names seed data"
	task :seed_data => :environment do
		Import::BoardNamesService.call(Rails.root.join('lib', 'data', 'boardnames.xlsx'))
	end
end