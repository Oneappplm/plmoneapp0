class ProviderSource < ApplicationRecord
  has_many :data, class_name: 'ProviderSourceData', inverse_of: :provider_source, dependent: :destroy
  has_many  :documents, class_name: 'ProviderSourceDocument', inverse_of: :provider_source, dependent: :destroy
  has_many :deas, class_name: 'ProviderSourcesDea', inverse_of: :provider_source, dependent: :destroy
  has_many :cds, class_name: 'ProviderSourcesCds', inverse_of: :provider_source, dependent: :destroy
  has_many :cmes, class_name: 'ProviderSourceCme', inverse_of: :provider_source, dependent: :destroy
  has_many :registrations, class_name: 'ProviderSourcesRegistration', inverse_of: :provider_source, dependent: :destroy

  accepts_nested_attributes_for :deas, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :cds, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :registrations, allow_destroy: true, reject_if: :all_blank


  belongs_to :practice_location, optional: true
  belongs_to :group_engage_provider, optional: true
  scope :current, ->{ find_by(current_provider_source: true) }
  # this will make it so that every user will have a different current provider source on the provider engage page
  scope :current_provider_source_by_current_user, ->(user_id) { find_by(created_by_user: user_id, current_provider_source: true) }
  default_scope { order(current_provider_source: :desc) }

  # these toggle switches will have default value of "no"
  REQUIRED_TOGGLE_SWITCHES_FIELDS = [
    'has_dea_registration_number', 'has_cds_registration_number', 'has_cds_registration_number',
    'state_license_specialty', 'other_id_voluntarily_medicare', 'medicare_field', 'medicaid_field',
    'specialties_ppo_directory', 'specialties_pos_directory', 'specialties_board_exam', 'undergraduate_school',
    'professional_school', 'has_training_program', 'an_instructor', 'has_hospital_privilege', 'has_admitting_arrangement',
    'has_sovereign_immunity', 'has_liability_coverage', 'is_self_insured', 'served_in_military', 'has_work_history',
    'has_employment_gap', 'belonged_to_prog_org', 'has_malpractice_claim', 'phone_coverage_field', 'practice_limitations_field',
    'practice_location_interpreter', 'practice_laboratory_services', 'practice_partner', 'all_practice_location'
  ]

  after_create :set_default_disclosure_answer
  after_create :set_default_answers_to_rqeuired_switch_toggles

  class << self
    def set_provider_source_disclosure_answers
      ProviderSource.all.each do |ps|
        DisclosureQuestion.all.each do |q|
          q_data = ps.data.find_key(q.slug)
          if q_data
            ProviderSourceData.create(provider_source_id: ps.id, data_key: q.slug, data_value: 'no')
          else
            q_data.update_attribute('data_value', 'no')
          end
        end
      end
    end

    def transfer_to_group_engage_providers
      ProviderSource.find_each do |provider_source|
        ProviderSource::TransferToGroupEngageProvidersService.call(provider_source)
      end
    end
  end

  def provider_name = "#{full_name}"
  def degree = fetch('degree_titles')
  def email_address = fetch('email_address')
  def from_provider_title = "Provider App"
  def user = User.find_by(email: email_address)

  def fetch(key = nil)
    finder(key)&.data_value
  end

  def fetch_many(keys = [])
    data.where(data_key: keys)
  end

  def add_data(key, value)
    datakey = data.find_or_create_by(data_key: key)
    datakey.update_attribute('data_value', value)
  end

  # this will be used for the HtmlUtils.toggle_button for the find_by there
  def finder(field = nil)
    data.find_by(data_key: field)
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

  # start of refactored progress bar in provider engage
  def home_and_address_progress
    percentage = 0
    fields_no_prerequisites = [
        'first_name', 'last_name', 'degree_titles',
        'state_of_practice', 'primary-practioner-type',
        'gi-country', 'address_line_1', 'city', 'ps-state',
        'telephone', 'email_address', 'zipcode'
      ]

      filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

      if filled_up_fields != 0
        percentage = ((filled_up_fields.to_f/fields_no_prerequisites.count.to_f) * 100).to_f
      end
      percentage.to_i
  end


  def personal_info_progress
    percentage = 0
    fields_no_prerequisites = [
      'ps-gender', 'ps-dob', 'ps-citizenship', 'reside-on-us', 'work-on-us',
      'permanent-work-permit', 'languages-you-speak', 'languages-you-write',
      'ethnicity', 'social-security-number'
    ]

    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    if filled_up_fields != 0
        percentage = ((filled_up_fields.to_f/fields_no_prerequisites.count.to_f) * 100).to_f
    end
    percentage.to_i
  end

  def general_info_completed?
    ![home_and_address_progress, personal_info_progress].any? {|e| e != 100}
  rescue
    false
  end

  def registration_ids_progress
    percentage = 0
    prerequisites = ['has_dea_registration_number', 'has_cds_registration_number', 'registration_id_form']
    with_prerequisites = ['professional_ids_progress_dea_fields','professional_ids_progress_cds_fields','professional_ids_progress_registration_fields']

    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}
      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def professional_ids_progress_dea_fields
    ['dea_expire_date']
  end

  def professional_ids_progress_cds_fields
    ['cds_expire_date']
  end

  def professional_ids_progress_registration_fields
    ['registration_number','registration_specialty','registration_issuing_board',
      'registration_address_1', 'registration_zipcode', 'registration_issue_date', 'registration_issue_state'
    ]
  end

  def licensure_progress
    percentage = 0
    prerequisites = ['state_license_specialty']
    with_prerequisites = ['licensure_progress_state_license_specialty_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def licensure_progress_state_license_specialty_fields
    [
      'license_type', 'license_number', 'license_status',
      'licensure_issue_date', 'licensure_expiration_date', 'licensure_practice_state',
      'licensure_primary_license', 'licensure_require_supervision'
    ]
  end

  def other_ids_certifications_progress
    percentage = 0
    prerequisites = ['medicare_field', 'medicaid_field', 'caqh_fields', 'other_cert_field' ]
    with_prerequisites = ['other_ids_certifications_progress_medicare_fields', 'other_ids_certifications_progress_medicaid_fields', 'other_ids_certifications_progress_other_fields', 'other_ids_certifications_progress_caqh_fields' ]
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def other_ids_certifications_progress_medicare_fields
    ['participating_medicare_number', 'participating_medicare_state']
  end


  def other_ids_certifications_progress_medicaid_fields
    ['participating_medicaid_state', 'participating_medicaid_number']
  end

  def other_ids_certifications_progress_other_fields
    ['other_certification_type', 'other_certification_expiration_date']
  end

  def other_ids_certifications_progress_caqh_fields
    ['caqh_number']
  end

  def professional_ids_completed?
    ![registration_ids_progress, licensure_progress, other_ids_certifications_progress].any?{|e| e != 100}
  rescue
    false
  end

  def health_plans_progress_v2
    percentage = 0
    fields_no_prerequisites = [
      'hp_health_plans'
    ]

    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    if filled_up_fields != 0
        percentage = ((filled_up_fields.to_f/fields_no_prerequisites.count.to_f) * 100).to_f
    end
    percentage.to_i
  end

  def health_plans_completed?
    ![health_plans_progress_v2].any?{ |e| e != 100 }
  rescue
    false
  end

  def specialties_progress_v2
    percentage = 0
    fields_no_prerequisites = [
      'special_ranking', 'specialty', 'specialties_ppo_directory', 'specialties_pos_directory',
    ]
    prerequisites = ['specialties_board_exam']
    with_prerequisites = ['specialties_board_exam_fields']
    prerequisite_field_values = fetch_many(prerequisites)&.pluck(:data_value)
    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    percentage = if prerequisite_field_values.include?('yes')
      prerequisites_with_yes = prerequisite_field_values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end

      fields_to_answer = fields_to_fill_up.flatten + prerequisites + fields_no_prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100

    else
      fields_to_answer = (fields_no_prerequisites + prerequisites).flatten
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    end
    percentage.to_i
  end

  def specialties_board_exam_fields
    ['failed_board_date', 'failed_exam_certifying_board', 'failed_board_reason']
  end

  def speacialties_completed?
    ![specialties_progress_v2].any?{ |e| e != 100}
  rescue
    false
  end

  def education_progress_v2
    percentage = 0
    prerequisites = ['undergraduate_school', 'professional_school']
    with_prerequisites = ['education_undergrad_fields', 'education_graduate_fields']  # Get the answer for toggle switchese that is prerequisite of additional fields

    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def education_undergrad_fields
    [
      'usd_school_location', 'usd_undergraduate_school_name',
      'usd_address_line1', 'usd_city', 'usd_zipcode', 'usd_degree_awarded',
      'incomplete_undergrad', 'usd_date_graduation'
    ]
  end

  def education_graduate_fields
    [
      'education_types', 'prof_school_location', 'psd-psn', 'psd-address-line1',
      'psd-city', 'psd-zipcode', 'psd-telephone-number', 'psd-degree-awarded',
      'incomplete_prof', 'prof_date_graduation'
    ]
  end

  def training_progress_v2
    percentage = 0
    prerequisites = ['has_training_program']
    with_prerequisites = ['training_has_training_program_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def training_has_training_program_fields
    [
      'tf-location', 'tf-psn', 'tf-address-line1', 'tf-city',
      'tf-zipcode', 'tr_training_types', 'tr_specialties',
      'tf-start-date', 'tf-end-date', 'incomplete_training'
    ]
  end

  def teaching_appointments_progress_v2
    percentage = 0
    prerequisites = ['an_instructor']
    with_prerequisites = ['teaching_appointments_an_instructor_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact
      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def teaching_appointments_an_instructor_fields
    [
      'taf-location', 'taf-psn', 'taf-address-line1', 'taf-city',
      'taf-zipcode', 'taf-end-date'
    ]
  end

  def education_and_training_completed?
    ![education_progress_v2, training_progress_v2, teaching_appointments_progress_v2].any?{|e| e != 100}
  rescue
    false
  end

  def medical_education_progress
    percentage = 0
    total_cme_fields_with_answer = []
    total_cme_fields = self&.cmes.pluck(:training,:month_attended,:year_attended,:hours).flatten
    total_cme_fields_with_answer << self.fetch('cme_requested_credentials')
    total_cme_fields_with_answer = total_cme_fields&.compact&.reject(&:empty?)
    if self.fetch("cme_credit") == 'yes'
       percentage = (total_cme_fields_with_answer.count.to_f/total_cme_fields.count.to_f) * 100
      # percentage = 50
    else
      if !self.fetch('cme_requested_credentials').blank?
        percentage = 100
      end
    end
    percentage.to_i
  rescue
    0
  end

  def affiliation_info_progress
    percentage = 0
    prerequisites = [ 'has_admitting_arrangement', 'has_hospital_privilege']
    with_prerequisites = ['affiliation_info_progress_has_admitting_arrangement_fields', 'affiliation_info_progress_has_hospital_privilege_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def affiliation_info_progress_has_hospital_privilege_fields
    [
      'state_abbr', 'hp-facility-name', 'hp-mso-address-line1',
      'hp-city', 'hp-zipcode', 'hp-mso-telephone-number', 'hp-mso-fax-number', 'mso-department-name'
    ]
  end

  def affiliation_info_progress_has_admitting_arrangement_fields
    [
      'admit_state', 'facility-name', 'facility-address-line1', 'facility-zipcode'
    ]
  end

  def affiliation_info_completed?
    ![affiliation_info_progress].any?{|e| e != 100}
  rescue
    false
  end

  def professional_liability_progress_v2
    percentage = 0
    prerequisites = []
    fields_no_prerequisites = ['has_sovereign_immunity']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      insured = fetch('is_self_insured')
      fields_to_fill_up = if insured == 'yes'
        self_insured_yes_fields
      else
        self_insured_no_fields
      end
      fields_to_answer = fields_to_fill_up + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
     (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
  end

  def self_insured_yes_fields
    [
      'lf-self-insured-policy-name', 'lf-self-insured-policy-number', 'lf-self-insured-carrier-name',
      'lf-self-insured-coverage-amount', 'lf-self-insured-email-aggregate-coverage', 'lf-self-insured-original-effective-date',
      'lf-self-insured-original-expiration-date'
    ]
  end

  def self_insured_no_fields
    [
      'lf-carrier-location', 'lf-carrier-name', 'lf-address-line1', 'lf-city', 'lf-zipcode', 'lf-policy-number',
      'lf-not-insured-coverage-amount', 'lf-not-insured-email-aggregate-coverage', 'lf-not-insured-original-effective-date',
      'lf-not-insured-original-expiration-date'
    ]
  end

  def professional_liability_completed?
    ![professional_liability_progress_v2].any?{|e| e != 100}
  rescue
    false
  end

  def work_history_military_progress
    percentage = 0
    prerequisites = ['served_in_military']
    with_prerequisites = ['work_history_military_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def work_history_military_fields
    [ 'military_enlist_base_of_service' ]
  end

  def work_history_employment_progress
    percentage = 0
    prerequisites = ['has_work_history']

    with_prerequisites = ['work_history_employment_fields']    # Get the answer for toggle switchese that is prerequisite of additional fields

    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}
      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def work_history_employment_fields
    [
      'edc-employment-location', 'edc-practice-employer-name', 'edc-address-line1',
      'edc-city', 'edc-zipcode', 'edc-telephone-number', 'edc-fax-number',
      'edc-email', 'edc-contact-method', 'edc-start-date', 'edc-end-date', 'edc_collab'
    ]
  end

  def work_history_employment_gap_progress
    percentage = 0
    prerequisites = ['has_employment_gap']
    with_prerequisites = ['work_history_employment_gap_fields']

    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}
      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def work_history_employment_gap_fields
    [
      'gap_start_date', 'gap_end_date', 'gap_reason', 'gap_explanation'
    ]
  end

  def professional_references_progress
    percentage = 0
    fields_no_prerequisites = [
      'rf-first-name', 'rf-last-name', 'rf-degree', 'rf-address-line1',
      'rf-city', 'rf-state', 'rf-zipcode', 'rf-fax', 'rf-email-address', 'rf-association-start-date', 'rf-association-end-date'
    ]

    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    if filled_up_fields != 0
        percentage = ((filled_up_fields.to_f/fields_no_prerequisites.count.to_f) * 100).to_f
    end
    percentage.to_i
  end

  def professional_organization_progress
    percentage = 0
    prerequisites = ['belonged_to_prog_org']
    with_prerequisites = ['belonged_to_prog_org_fields']

    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}
      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def belonged_to_prog_org_fields
    ['prof_organization_name']
  end

  def work_history_completed?
    ![
      work_history_military_progress,
      work_history_employment_progress,
      work_history_employment_gap_progress,
      professional_references_progress,
      professional_organization_progress
    ].any?{|e| e != 100}
  rescue
    false
  end

  def credentialing_contact_progress
    percentage = 0
    fields_no_prerequisites = [
      'cc-city', 'cc-state', 'cc-zipcode', 'cc-fax-number', 'cc-email-address'
    ]

    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    if filled_up_fields != 0
        percentage = ((filled_up_fields.to_f/fields_no_prerequisites.count.to_f) * 100).to_f
    end
    percentage.to_i
  end

  def practice_location_progress_v2
    percentage = 0
    fields_to_fill_up = ['all_practice_location']

    if practice_location_general_info_started?
      fields_to_fill_up = fields_to_fill_up + practice_location_general_information_fields
    end

    if practice_location_contacts_started?
      fields_to_fill_up = fields_to_fill_up + practice_location_contacts_fields
    end

    if practice_location_midlevel_practitioner_started?
      fields_to_fill_up = fields_to_fill_up + practice_location_midlevel_practitioner_fields
    end

    if practice_location_partners_started?
      fields_to_fill_up = fields_to_fill_up + practice_location_partners_fields
    end

    answered = fetch_many(fields_to_fill_up)&.pluck(:data_value).compact.reject(&:empty?).count
    percentage = (answered.to_f/(fields_to_fill_up.count).to_f) * 100
    percentage.to_i
  end

  def practice_location_general_information_fields
    [
      'practice_name', 'practice_address_line_1', 'practice_city',
      'dco_state', 'practice_zip_code', 'practice_telephone_number',
      'practice_type', 'practice_type_tax_id', 'group_npi_field',
      'practice_practitioner_profiles_5'
    ]
  end

  def practice_location_contacts_fields
    [
      'contact_office_first_name', 'contact_office_last_name', 'contact_office_address_line_1',
      'contact_office_city', 'contact_office_state', 'contact_office_zip_code', 'contact_office_telephone_number',
      'contact_billing_address_line_1','contact_billing_city', 'contact_billing_state', 'contact_billing_zip_code',
      'contact_billing_telephone_number', 'contact_remittance_city', 'contact_remittance_state'
    ]
  end

  def practice_location_midlevel_practitioner_fields
    [ 'practice_midlevel_first_name', 'practice_midlevel_last_name', 'practice_midlevel_degree' ]
  end

  def practice_location_partners_fields
    [
      'practice_partners_first_name', 'practice_partners_last_name', 'practice_partners_degree', 'practice_partners_specialty',
      'practice_partners_state'
    ]
  end

  def practice_location_general_info_started?
    fields = fetch_many(practice_location_general_information_fields)&.pluck(:data_value).compact
    !fields.blank?
  end

  def practice_location_contacts_started?
    fields = fetch_many(practice_location_contacts_fields)&.pluck(:data_value)&.compact&.reject(&:empty?)
    !fields.blank?
  end

  def practice_location_midlevel_practitioner_started?
    fields = fetch_many(practice_location_midlevel_practitioner_fields)&.pluck(:data_value)&.compact&.reject(&:empty?)
    !fields.blank?
  end

  def practice_location_partners_started?
    fields = fetch_many(practice_location_partners_fields)&.pluck(:data_value)&.compact&.reject(&:empty?)
    !fields.blank?
  end
  def covering_colleagues_progress
    percentage = 0
    prerequisites = ['covering_colleague']
    with_prerequisites = ['covering_colleague_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| send(with_prerequisites[y])}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def covering_colleague_fields
    ['specialty']
  end

  def unique_circumstances_progress
    # no required fields here to default 100
    100
  end

  def practice_information_completed?
    ![credentialing_contact_progress, practice_location_progress_v2, covering_colleagues_progress].any?{|e| e != 100}
  rescue
    false
  end

  def disclosure_progress_v2
    percentage = 0
    prerequisites = DisclosureQuestion.all.pluck(:slug)
    with_prerequisites = prerequisites.map{|m| "#{m}_explanation"}
    values = fetch_many(prerequisites)&.pluck(:data_value)

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index{|v,idx| idx if (v != 'no' && v != nil)}.compact

      fields_to_fill_up = prerequisites_with_yes.map{|y| with_prerequisites[y]}

      prerequisites_with_yes.reverse_each do |idx|
        prerequisites.delete_at(idx)
      end
      fields_to_answer = fields_to_fill_up.flatten + prerequisites
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count
      (answered.to_f/(fields_to_answer.count).to_f) * 100
    else
      100
    end
    percentage.to_i
  end

  def add_to_roster group_engage_provider
    ['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn'].each  do |column|
      data_key = filtered_data_key(column)
      data_value = group_engage_provider.send(column)

      add_data(data_key, data_value) if data_value.present?
    end
  end

  def filtered_data_key column
    case column
    when 'data_of_birth'
      'ps-dob'
    when 'ssn'
      'social-security-number'
    else
      column
    end
  end

  def send_invite
    ProviderSource::SendInviteService.call(self)
  end

  def global_invitation_count
    self.class.where(group_engage_provider_id: group_engage_provider_id).where.not(invitation_count: [nil, 0]).take.invitation_count
  rescue
    0
  end

  def global_invitation_sent_at
    self.class.where(group_engage_provider_id: group_engage_provider_id).where.not(invitation_sent_at: nil).take.invitation_sent_at
  rescue
    nil
  end

  def created_by
    User.find_by(id: self.created_by_user)
  rescue
    nil
  end

  def create_dea
    ProviderSourcesDea.create(provider_source_id: self.id)
  end

  def create_cds
    ProviderSourcesCds.create(provider_source_id: self.id)
  end

  def create_registration
    ProviderSourcesRegistration.create(provider_source_id: self.id)
  end

  def create_cme
    ProviderSourceCme.create(provider_source_id: self.id)
  end

  private

  # will set provider source disclosure answer to no as default is needed to calculate percentage of progress
  def set_default_disclosure_answer
    DisclosureQuestion.all.each do |question|
      ProviderSourceData.find_or_create_by(provider_source_id: self.id, data_key: question.slug, data_value: 'no')
    end
  end

  def set_default_answers_to_rqeuired_switch_toggles
    # Made this so that all required toggles have default answers NO
    # **** by default all toggle switches are always NO
    REQUIRED_TOGGLE_SWITCHES_FIELDS.each do |toggle|
      ProviderSourceData.find_or_create_by(provider_source_id: self.id, data_key: toggle, data_value: 'no')
    end
  end

  def delete_group_engage_provider
    group_engage_provider.destroy if group_engage_provider.present?
  end
end