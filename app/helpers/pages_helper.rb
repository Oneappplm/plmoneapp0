module PagesHelper
  def page_data_group action_name, page
    date_group = if action_name == 'provider_source'
      if page.nil?
        'home_and_address_progress'
      elsif ['personal_info'].include?(page)
        'personal_info_progress'
      elsif ['professional_ids'].include?(page)
        'registration_ids_progress'
      elsif ['licensure'].include?(page)
        'licensure_progress'
      elsif ['other_ids'].include?(page)
        'other_ids_certifications_progress'
      elsif ['health_plans'].include?(page)
        'health_plans_progress_v2'
      elsif ['specialties'].include?(page)
        'specialties_progress_v2'
      elsif ['education_training'].include?(page)
        'education_progress_v2'
      elsif ['training'].include?(page)
        'training_progress_v2'
      elsif ['teaching_appointments'].include?(page)
        'teaching_appointments_progress_v2'
      elsif ['affiliation_information'].include?(page)
        'affiliation_info_progress'
      elsif ['work_history'].include?(page)
        'work_history_military_progress'
      elsif ['employment'].include?(page)
        'work_history_employment_progress'
      elsif ['employment_gap'].include?(page)
        'work_history_employment_gap_progress'
      elsif ['prof_references'].include?(page)
        'professional_references_progress'
      elsif ['prof_organization'].include?(page)
        'professional_organization_progress'
      elsif ['practice_information'].include?(page)
        'credentialing_contact_progress'
      elsif ['practice_location'].include?(page)
        'practice_location_progress_v2'
      elsif ['covering_colleagues'].include?(page)
        'covering_colleagues_progress'
      elsif ['unique_circumstances'].include?(page)
        'unique_circumstances_progress'
      elsif ['disclosure'].include?(page)
        'disclosure_progress_v2'
      elsif ['professional_liability'].include?(page)
        'professional_liability_progress_v2'
      end
    end
  end
end