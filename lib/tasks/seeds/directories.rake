namespace :directories do
	desc "Generate Directory Seed Data"
	task :seed_data => :environment do
		Directory.generate_directories
	end
end

