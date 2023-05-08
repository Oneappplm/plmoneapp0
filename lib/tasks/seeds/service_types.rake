namespace :services do
  desc "Generate Services Seed Data"
  task :seed_data => :environment do
    Service.generate_services
  end
end
