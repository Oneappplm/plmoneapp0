namespace :client_portal do
	desc "Generate Client Portal Seed Data"
	task :seed_data => :environment do
		Client.create_dummies
	end
end