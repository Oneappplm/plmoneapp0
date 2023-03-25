namespace :specialties do
	desc "Add specialties seed data"
	task :seed_data => :environment do
		Import::SpecialtiesService.call(Rails.root.join('lib', 'data', 'specialties.xlsx'))
	end
end
