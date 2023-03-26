namespace :update_client_specialties do
	desc "Update client specialties"
	task :seed_data => :environment do
		Client.update_specialties
	end
end