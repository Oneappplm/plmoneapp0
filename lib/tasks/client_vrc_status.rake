namespace :client_vrc_status do
	desc "Add VRC status to existing clients"
	task :seed_data => :environment do
		Client.add_vrc_statuses
	end
end