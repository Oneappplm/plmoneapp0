namespace :languages do
	desc "Add Languages seed data"
	task :seed_data => :environment do
		Import::LanguagesService.call(Rails.root.join('lib', 'data', 'languages.csv'))
	end
end
