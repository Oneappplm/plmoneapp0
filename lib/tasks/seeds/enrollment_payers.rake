namespace :enrollment_payers do
	desc "Add enrollment_payers seed data"
	task :seed_data => :environment do
		Import::EnrollmentPayersService.call(Rails.root.join('lib', 'data', 'enrollment-payers.xlsx'))
	end
end