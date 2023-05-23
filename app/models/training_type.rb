class TrainingType < ApplicationRecord
  default_scope { order(:name)}

	def self.generate_trainings
		trainings = [
                 'Internship/Residency', 'Academic', 'Assistanship', 'Clinical', 'Fellowship', 'Internship', 'Other Training', 'Precertorship', 'Procedural Certificate Course', 'Research' 'Residency', 'Rotating', 'Teaching Appointment', 'Transitional'
    ]

    trainings.each do |training|
      TrainingType.find_or_create_by(name: training.strip)
    end
	end
end