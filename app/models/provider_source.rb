class ProviderSource < ApplicationRecord
	has_many :data, class_name: 'ProviderSourceData',	inverse_of: :provider_source, dependent: :destroy
	has_many	:documents, class_name: 'ProviderSourceDocument', inverse_of: :provider_source, dependent: :destroy
	scope :current, ->{ find_by(current_provider_source: true) }
	default_scope {	order(current_provider_source: :desc) }

  def provider_name = "#{full_name}"
  def from_provider_title = "Provider App"

	def fetch(key = nil)
		data.find_by(data_key: key)&.data_value
	end

	def full_name
	 "#{fetch('first_name')} #{fetch('last_name')}"
	end

	def states
		eval(fetch('state_or_practice'))
  rescue
    nil
	end

  def is_answer_yes?(question_slug)
    # this is for disclosures related models is DisclosureQuestion and ProviderSourceData
    fetch(question_slug) == 'yes'
  end

  def disclosure_explanation(question_slug)
    fetch("#{question_slug}_explanation")
  rescue
    ''
  end

	def current_provider_source?
	 current_provider_source ? 'Yes' : 'No'
	end

  def self.test_document_upload
		provider_source = ProviderSource.current
		document = provider_source.documents.new
		document.file_path = File.open(File.join(Rails.root, 'lib', 'data', 'languages.csv'))
		document.file_name = 'languages.csv'
		document.save
		document.file_path.url
	end

  # progresses - part where total progress is calculated
  def general_information_progress
   total_fields_required = (personal_info + general_name_address + general_info_with_prerequesites).count
   completed_fields = required_fields_counter(personal_info) + required_fields_counter(general_name_address) + required_fields_with_prerequisetes_has_answer(general_info_with_prerequesites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
  end

  def professional_ids_progress
    total_fields_required = (registration_ids_with_prerequisites + licensures_with_prerequisites + certifications_with_prerequisites + certifications).count
    completed_fields = required_fields_counter(certifications) + required_fields_with_prerequisetes_has_answer(registration_ids_with_prerequisites) + required_fields_with_prerequisetes_has_answer(licensures_with_prerequisites) + required_fields_with_prerequisetes_has_answer(certifications_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   # total_fields_required
  end

  def health_plans_progress
    total_fields_required = (health_plans).count
    completed_fields = required_fields_counter(health_plans)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
  end

  def disclosure_progress
    total_fields_required = disclosures.count
    completed_fields = required_fields_counter(disclosures)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
  end

  def education_traning_progess
    total_fields_required = (education_with_prerequisites).count
    completed_fields = required_fields_with_prerequisetes_has_answer(education_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
  end

  # no prerequisites - this part contains required fields that don't have a hidden field

  def certifications
    infos = ['has_opted_medicare']
  end

  def health_plans
    infos = ['health_plans', 'hospitals', 'directories']
  end

  def personal_info
   # only count the required fields in progress
   infos =  [
      'ps-gender', 'ps-citizenship', 'reside-on-us', 'work-on-us', 'ps-dob',
      'permanent-work-permit', 'languages-you-speak', 'languages-you-write', 'ethnicity'
    ]
  end

  def general_name_address
    infos = [
      'first_name', 'last_name', 'degree_titles', 'state_or_practice', 'primary-practioner-type',
      'address_line_1', 'telephone', 'city', 'ps-state', 'zipcode', 'email_address'
    ]
  end

  def disclosures
    infos = DisclosureQuestion.all.pluck(:slug)
  end

  # with prerequisites - these fields will show hidden required fields

  def general_info_with_prerequesites
    # [0] = field to check, [1] = will include in progress base on answer, [2] = expected answer to make [1] included in progress
    fields_with_prerequisites = [['ps-ssn','social-security-number', 'yes']]
    prerequisite_checker(fields_with_prerequisites)
  end

  def registration_ids_with_prerequisites
    # [0] = field to check, [1] = will include in progress base on answer, [2] = expected answer to make [1] included in progress
    infos = [
         ['has_dea_registration_number', 'dea_registration_number', 'yes'],
         ['has_dea_registration_number', 'dea_registration_state', 'yes'],
         ['has_dea_registration_number', 'dea_expire_date', 'yes'],
         ['has_cds_registration_number', 'cds_registration_number', 'yes'],
         ['has_cds_registration_number', 'cds_registration_state', 'yes'],
         ['has_cds_registration_number', 'cds_issue_date', 'yes'],
         ['has_cds_registration_number', 'cds_expire_date', 'yes'],
         ['has_cds_registration_number', 'cds_practice_state_option', 'yes'],
         ['has_registration_number', 'registration_number', 'yes'],
         ['has_registration_number', 'registration_specialty', 'yes'],
         ['has_registration_number', 'registration_issuing_board', 'yes'],
         ['has_registration_number', 'registration_address_1', 'yes'],
         ['has_registration_number', 'registration_city', 'yes'],
         ['has_registration_number', 'registration_state', 'yes'],
         ['has_registration_number', 'registration_zipcode', 'yes'],
         ['has_registration_number', 'registration_issue_date', 'yes'],
         ['has_registration_number', 'registration_expiration_date', 'yes'],
         ['has_registration_number', 'registration_under_number', 'yes']
    ]
    prerequisite_checker(infos)
  end

  def licensures_with_prerequisites
    infos = [
          ['has_state_license', 'licensure_state', 'yes'],
          ['has_state_license', 'license_type', 'yes'],
          ['has_state_license', 'license_number', 'yes'],
          ['has_state_license', 'license_status', 'yes'],
          ['has_state_license', 'licensure_issue_date', 'yes'],
          ['has_state_license', 'licensure_expiration_date', 'yes'],
          ['has_state_license', 'licensure_practice_state', 'yes'],
          ['has_state_license', 'licensure_primary_license', 'yes'],
          ['licensure_require_supervision', 'licensure_sponsor_fname', 'yes'],
          ['licensure_require_supervision', 'licensure_sponsor_lname', 'yes'],
    ]
    prerequisite_checker(infos)
  end

  def certifications_with_prerequisites
    infos = [
          ['participating_medicare', 'participating_medicare_number', 'yes'],
          ['participating_medicare', 'participating_medicare_state', 'yes'],
          ['participating_medicaid', 'participating_medicaid', 'yes'],
          ['participating_medicaid', 'participating_medicaid_state', 'yes'],
          ['has_other_certifications', 'other_certification_type', 'yes']

    ]
    prerequisite_checker(infos)
  end

  def education_with_prerequisites
    infos = [
          ['undergrad_school', 'usd_undergraduate_school_name', 'yes'],
          ['undergrad_school', 'usd_address_line1', 'yes'],
          ['undergrad_school', 'usd_degree_awarded', 'yes'],
          ['undergrad_school', 'usd_zipcode', 'yes'],
          ['undergrad_school', 'usd_city', 'yes'],
          ['undergrad_school', 'complete_undergrad', 'yes'],
          ['undergrad_school', 'usd_date_graduation', 'yes'],
          ['undergrad_school', 'usd_school_location', 'yes'],
          ['incomplete_undergrad', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', '', 'yes'],
          ['professional_school', 'prof_date_start', 'yes'],
          ['professional_school', 'prof_date_graduation', 'yes'],
          ['incomplete_prof', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['has_training_program', '', 'yes'],
          ['incomplete_training', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes'],
          ['an_instructor', '', 'yes']
    ]
    prerequisite_checker(infos)
  end


  # array checkers here

  def prerequisite_checker infos
    fields_to_count = []
    infos.each do |fields|
      if (fetch(fields[0]).blank? == false) && (fetch(fields[0]) == fields[2])
          fields_to_count << fields[1]
      end
    end
    fields_to_count
  end

  # this part is to check if hidden fields that require a prerequisite question has answers
  # had to differentiate this to the visible fields since when onload data saving happens
  # the hidden fields were not included due to display none properties
  def required_fields_with_prerequisetes_has_answer infos
    arr = []
    infos.each do |info|
      if fetch(info).blank? == false
        arr << fetch(info)
      end
    end
    arr.count
  end

  def required_fields_counter infos
    arr = []
    infos.each do |info|
      arr << (fetch(info).blank?)
    end
    arr.count(false)
  end
end