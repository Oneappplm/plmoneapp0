namespace :qualifacts do
	desc "Add Qualifacts Seed Data to Provider Source"
	task	:seed_data => :environment do
		puts "This is no seed data	for Qualifacts."
	end
	task :load_data => :environment do
		Import::QualifactsService.call(Rails.root.join('lib', 'data', 'qualifacts-provider-data.xlsx'))
	end
end