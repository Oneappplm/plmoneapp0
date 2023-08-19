class EnrollmentGroupsSvcLocation < ApplicationRecord
  belongs_to :enrollment_group


  def selected_languages
    self.primary_service_interpreter_language? ? self.primary_service_interpreter_language.split(',') : ''
  rescue
    ''
  end

  def selected_states
    self.primary_service_telehealth_only_state ? self.primary_service_telehealth_only_state.split(',') : ''
  rescue
    ''
  end

  def state
    State.find_by(id: self.primary_service_non_office_area)&.name
  rescue
    ''
  end
end