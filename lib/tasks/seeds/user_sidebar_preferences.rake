namespace :user_sidebar_preferences do
  desc "Create user sidebar preferences"
  task :seed_data => :environment do
    User.set_user_sidebar_preferences
  end
end