namespace :role_based_accesses do
	desc "Generate Role Based Access Seed Data"
	task :seed_data => :environment do
		User.pluck(:user_role).uniq.each do |role|
			RoleBasedAccess.initialize_access(role)
		end
	end
end