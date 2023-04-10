namespace :hospitals do
	desc "Generate Hospitals Seed Data"
	task :seed_data => :environment do
		Hospital.generate_hospitals
	end
end

