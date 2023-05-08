namespace :vrc do
	desc "Generate Virtual Review Committee Seed Data"
	task :seed_data => :environment do

		default_data = {
			provider_name: 'Bennet, Lindsay',
			provider_type: 'Physician Assistant',
			state: 'OR',
			cred_cycle: 'Credential',
			psv_completed_date: rand(10.weeks.ago..1.day.ago),
			review_level: 'Expedited',
			recred_due_date: rand(10.weeks.ago..1.day.ago),
			review_date: rand(10.weeks.ago..1.day.ago),
			committee_date: rand(10.weeks.ago..1.day.ago),
			vote_date: rand(10.weeks.ago..1.day.ago),
			status: 'Approved',
			progress_status: 'completed'
		}

		['Bennet, Lindsay', 'Bose, Paul', 'Diaz, Fynn', 'Calibre, Reese', 'Doe, John', 'Dela Cruz, Juan', 'Penduko, Pedro'].each_with_index do |provider_name, index|
			vrc_data = VirtualReviewCommittee.new(default_data)
			vrc_data.provider_name = provider_name
			if index == 1 || index == 2
				vrc_data.progress_status = 'assigned'
			elsif index == 5
				vrc_data.progress_status = 'to_be_assigned'
			end
			vrc_data.save
		end

	end
	task :import_data => :environment do
		VirtualReviewCommittee.destroy_all
		Import::VirtualReviewCommitteeService.call(Rails.root.join('lib', 'data', 'vrc.csv'))
	end
end