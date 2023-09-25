namespace :serviced_populations do
	desc "Generate Serviced Populations Seed Data"
	task :seed_data => :environment do
		ServicedPopulation.generate_serviced_populations
	end
end