namespace :users	do
	desc "Create admin account"

	task :seed_data => :environment do
		User.create_admin
	end

	task :generate_api_token	=> :environment do
		User.all.each do |user|
			user.generate_api_token
			user.save(validate: false)
		end
	end
end