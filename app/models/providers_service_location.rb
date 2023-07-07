class ProvidersServiceLocation < ApplicationRecord
  belongs_to :provider


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
end