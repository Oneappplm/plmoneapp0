namespace :plmhealthoneapp do
	desc "Run all Rake tasks in the lib/tasks/seeds directory"
	task :seed_initial_data => :environment do
			Dir.glob(File.join(Rails.root, 'lib', 'tasks', 'seeds', '*.rake')).each do |task|
						namespace = File.basename(task, '.rake')
      Rake.application.add_import(task)
      Rake.application.load_imports
      tasks = Rake::Task.tasks.select { |t| t.name.starts_with?("#{namespace}:") }.map(&:name)
						puts "\n=============================================================="
						puts "Starting rake task: #{namespace}:seed_data at #{Time.now}"
      Rake.application.invoke_task("#{namespace}:seed_data") if tasks.any?
						puts "Finished rake task: #{namespace}:seed_data at #{Time.now}"
						puts "=============================================================="
			end
	end
end