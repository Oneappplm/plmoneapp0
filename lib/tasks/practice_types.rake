namespace :practice_types do
  desc "Generate Practice Types Seed Data"
  task :seed_data => :environment do
    PracticeType.generate_types
  end
end
