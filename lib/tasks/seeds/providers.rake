namespace :providers do
	desc "Add providers seed data"
	task :seed_data => :environment do
		Import::EnrollmentTrackingProvidersService.call(Rails.root.join('lib', 'data', 'enrollment-tracking-providers.xlsx'))
	end
end
