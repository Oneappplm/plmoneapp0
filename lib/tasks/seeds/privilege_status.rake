namespace :privilege_status do
  desc "Generate Privilege Status Seed Data"
  task :seed_data => :environment do
    PrivilegeStatus.generate_privileges
  end
end