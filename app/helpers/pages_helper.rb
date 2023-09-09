module PagesHelper
  def page_data_group action_name, page
    date_group = if action_name == 'provider_source'
      if page.nil? or ['personal_info'].include?(page)
        'general_information_progress'
      elsif ['professional_ids', 'licensure', 'other_ids'].include?(page)
        'professional_ids_progress'
      elsif ['health_plans'].include?(page)
        'health_plans_progress'
      elsif ['disclosure'].include?(page)
        'disclosure_progress'
      elsif ['education_training', 'training','teaching_appointments'].include?(page)
        'education_traning_progess'
      elsif ['specialties'].include?(page)
        'specialties_progress'
      elsif ['affiliation_information'].include?(page)
        'affiliation_progress'
      elsif ['professional_liability'].include?(page)
        'professional_liability_progress'
      elsif ['employment', 'employment_gap', 'prof_references', 'prof_organization', 'work_history'].include?(page)
        'work_history_progress'
      elsif ['practice_information', 'practice_location', 'covering_colleagues', 'unique_circumstances'].include?(page)
        'practice_information_progress'
      end
    end
  end
end