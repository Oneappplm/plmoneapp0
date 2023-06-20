namespace :practitioner_profiles do
  desc "Generate Practitioner Profiles Seed Data"
  task :seed_data => :environment do
    PractitionerProfile.generate_profiles
  end
end
