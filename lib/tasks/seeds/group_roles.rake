namespace :group_roles do
	desc "Generate Group Roles Seed Data"
	task :seed_data => :environment do
		GroupRole.generate_group_roles
	end
end