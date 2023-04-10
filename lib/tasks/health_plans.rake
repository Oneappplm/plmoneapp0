namespace :health_plans do
	desc "Generate Health Plans Seed Data"
	task :seed_data => :environment do
		HealthPlan.generate_plans
	end
end

