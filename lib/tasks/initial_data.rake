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

	# rake 'plmhealthoneapp:update_client_name[client_name]' e.g.: rake 'plmhealthoneapp:update_client_name[plmhealthoneapp]'
	task :update_client_name, [:client_name] => :environment do |task, args|
		desc "Update client name"
		client_name = args.client_name
		puts "Updating client name to #{client_name}..."
		Setting.update_setting({client_name: client_name})
	end
end