namespace :training_types do
  desc "Generate Training Types Seed Data"
  task :seed_data => :environment do
    TrainingType.generate_trainings
  end
end