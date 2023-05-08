namespace :disclosure_categories do
	desc "Generate Disclosure Question Categories Seed Data"
	task :seed_data => :environment do
		DisclosureCategory.generate_categories
	end
end
