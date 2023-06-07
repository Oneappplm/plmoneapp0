namespace :visa_types do
  desc "Generate Visa Types Seed Data"
  task :seed_data => :environment do
    VisaType.generate_visas
  end
end