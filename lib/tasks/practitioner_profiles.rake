namespace :practictioner_profles do
  desc "Generate Practitioner Profiles Seed Data"
  task :seed_data => :environment do
    PractitionerProfile.generate_profiles
  end
end
