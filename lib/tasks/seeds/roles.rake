namespace :roles	do
	desc "Add default roles"
	task :seed_data => :environment do
		Role.load_data
	end
end