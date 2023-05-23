namespace :education_types do
  desc "Generate Education Types Seed Data"
  task :seed_data => :environment do
    EducationType.generate_types
  end
end