namespace :update_client_provider_types do
	desc "Update client provider types"
	task :seed_data => :environment do
		Client.update_provider_types
	end
end