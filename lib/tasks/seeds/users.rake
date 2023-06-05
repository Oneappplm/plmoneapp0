namespace :users	do
	desc "Create admin account"
	task :create_admin => :environment do
		User.create_admin
	end
end