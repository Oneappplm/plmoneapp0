namespace :admins	do
	desc "Create admin account"

	task :seed_data => :environment do
	 Admin.create(email: "admin1@plmhealth.com", password: "68V5HgaMC")
	end
end
