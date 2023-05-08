namespace :disclosure_questions do
	desc "Generate Disclosure Questions Seed Data"
	task :seed_data => :environment do
		DisclosureQuestion.generate_category_question
	end
end
