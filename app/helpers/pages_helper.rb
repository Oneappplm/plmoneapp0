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
      elsif ['education_training'].include?(page)
        'education_traning_progess'
      end
    end
  end
end