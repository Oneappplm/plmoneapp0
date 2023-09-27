namespace :method_resolutions do
	desc "Add method_resolutions seed data"
	task :seed_data => :environment do
		MethodResolution.generate_method_resolutions
	end
end