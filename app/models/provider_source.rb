class ProviderSource < ApplicationRecord
	has_many :data, class_name: 'ProviderSourceData',	inverse_of: :provider_source, dependent: :destroy
	has_many	:documents, class_name: 'ProviderSourceDocument', inverse_of: :provider_source, dependent: :destroy
  belongs_to :practice_location, optional: true
  belongs_to :group_engage_provider, optional: true
	scope :current, ->{ find_by(current_provider_source: true) }
	default_scope {	order(current_provider_source: :desc) }

  after_create :set_default_disclosure_answer

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

  # progresses - part where total progress is calculated
  def general_information_progress
   total_fields_required = (personal_info + general_name_address + general_info_with_prerequesites).count
   completed_fields = required_fields_counter(personal_info) + required_fields_counter(general_name_address) + required_fields_with_prerequisetes_has_answer(general_info_with_prerequesites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
    rescue
      0
  end

  def professional_ids_progress
    total_fields_required = (registration_ids_with_prerequisites + licensures_with_prerequisites + certifications_with_prerequisites + certifications).count
    completed_fields = required_fields_counter(certifications) + required_fields_with_prerequisetes_has_answer(registration_ids_with_prerequisites) + required_fields_with_prerequisetes_has_answer(licensures_with_prerequisites) + required_fields_with_prerequisetes_has_answer(certifications_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   # total_fields_required
   rescue
      0
  end

  # example of not prerequisites
  def health_plans_progress
    total_fields_required = (health_plans).count
    completed_fields = required_fields_counter(health_plans)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  # def disclosure_progress
  #   total_fields_required = disclosures.count
  #   completed_fields = required_fields_counter(disclosures)
  #  ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
  #  rescue
  #     100
  # end

  # will continue this
  def disclosure_progress
    total_fields_required = (disclosures_with_prerequisites).count
    completed_fields = required_fields_with_prerequisetes_has_answer(disclosures_with_prerequisites)
    progress = if completed_fields == 0 && total_fields_required == 0
      100
    else
      ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
    end
    progress
   rescue
      100 #by default i made this 100 since the default answer to all disclosure question is NO
  end

  def education_traning_progess
    total_fields_required = (education_with_prerequisites + training_program_with_prerequisites + teaching_appointments_with_prerequisites).count
    completed_fields = required_fields_with_prerequisetes_has_answer(education_with_prerequisites) + required_fields_with_prerequisetes_has_answer(teaching_appointments_with_prerequisites) + required_fields_with_prerequisetes_has_answer(training_program_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  # example of both with not prerequisite and with prerequisite
  def specialties_progress
    total_fields_required = (specialties + specialties_with_prerequisites).count
    completed_fields = required_fields_counter(specialties) + required_fields_with_prerequisetes_has_answer(specialties_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  # example of pure fields with required condition to count
  def affiliation_progress
    total_fields_required = (affiliation_with_prerequisites).count
    completed_fields = required_fields_with_prerequisetes_has_answer(affiliation_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  def professional_liability_progress
    total_fields_required = (professional_liability + professional_liability_with_prerequisites).count
    completed_fields = required_fields_counter(professional_liability) + required_fields_with_prerequisetes_has_answer(professional_liability_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  def work_history_progress
    total_fields_required = (military_info_with_prerequisites + employment_with_prerequisites + employment_gap_with_prerequisites + professional_references + professional_organization_with_prerequisites).count
    completed_fields = required_fields_counter(professional_references) + required_fields_with_prerequisetes_has_answer(military_info_with_prerequisites) + required_fields_with_prerequisetes_has_answer(employment_with_prerequisites) + required_fields_with_prerequisetes_has_answer(employment_gap_with_prerequisites) + required_fields_with_prerequisetes_has_answer(professional_organization_with_prerequisites)
   ((completed_fields.to_f/total_fields_required.to_f) * 100).to_i
   rescue
      0
  end

  def practice_information_progress
    0
  end

  # no prerequisites - this part contains required fields that don't have a hidden field

  def certifications
    infos = ['has_opted_medicare']
  end

  def health_plans
    infos = ['hp_health_plans', 'hp_hospitals', 'hp_directories']
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
      'first_name', 'last_name', 'degree_titles', 'state_of_practice', 'primary-practioner-type',
      'address_line_1', 'telephone', 'city', 'ps-state', 'zipcode', 'email_address'
    ]
  end

  def disclosures
    infos = DisclosureQuestion.all.pluck(:slug)
  end

  def specialties
    infos = ['special_ranking', 'specialty', 'specialties_ppo_directory', 'specialties_pos_directory']
  end

  def professional_liability
    infos = ['has_sovereign_immunity', 'has_liability_coverage']
  end

  def professional_references
    infos = ['rf-first-name', 'rf-last-name', 'rf-degree',
              'rf-contact-method', 'rf-address-line1', 'rf-city',
              'rf-state', 'rf-zipcode' ,'rf-telephone-number', 'rf-fax',
              'rf-email-address', 'rf-association-start-date',
              'rf-association-end-date'
            ]
  end

  # with prerequisites - these fields will show hidden required fields

  def specialties_with_prerequisites
    infos = [
      ['sp_board_exam', 'failed_board_reason', 'yes'],
      ['sp_board_exam', 'failed_exam_certifying_board', 'yes'],
    ]
    prerequisite_checker(infos)
  end

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
          ['undergraduate_school', 'usd_undergraduate_school_name', 'yes'],
          ['undergraduate_school', 'usd_address_line1', 'yes'],
          ['undergraduate_school', 'usd_degree_awarded', 'yes'],
          ['undergraduate_school', 'usd_zipcode', 'yes'],
          ['undergraduate_school', 'usd_city', 'yes'],
          ['undergraduate_school', 'usd_date_graduation', 'yes'],
          ['undergraduate_school', 'usd_school_location', 'yes'],
          ['incomplete_undergrad', 'usd-reason', 'yes'],
          ['professional_school', 'education_types', 'yes'],
          ['professional_school', 'prof_school_location', 'yes'],
          ['professional_school', 'psd-psn', 'yes'],
          ['professional_school', 'psd-address-line1', 'yes'],
          ['professional_school', 'psd-city', 'yes'],
          ['professional_school', 'psd-zipcode', 'yes'],
          ['professional_school', 'psd-telephone-number', 'yes'],
          ['professional_school', 'psd-degree-awarded', 'yes'],
          ['professional_school', 'prof_school_location', 'yes'],
          ['professional_school', 'prof_date_start', 'yes'],
          ['professional_school', 'prof_date_graduation', 'yes']
    ]
    prerequisite_checker(infos)
  end

  def training_program_with_prerequisites
    infos = [
          ['has_training_program', 'tf-location', 'yes'],
          ['has_training_program', 'tf-psn', 'yes'],
          ['has_training_program', 'tf-address-line1', 'yes'],
          ['has_training_program', 'tf-city', 'yes'],
          ['has_training_program', 'tf-zipcode', 'yes'],
          ['has_training_program', 'tr_training_types', 'yes'],
          ['has_training_program', 'tr_specialties', 'yes'],
          ['has_training_program', 'tf-start-date', 'yes'],
          ['has_training_program', 'tf-end-date', 'yes'],
          ['has_training_program', 'training_location', 'yes'],
          ['incomplete_training', 'tf-reason', 'no'],
    ]
    prerequisite_checker(infos)
  end

  def teaching_appointments_with_prerequisites
    infos = [
          ['an_instructor', 'taf-address-line1', 'yes'],
          ['an_instructor', 'taf-psn', 'yes'],
          ['an_instructor', 'taf-location', 'yes'],
          ['an_instructor', 'taf-city', 'yes'],
          ['an_instructor', 'taf-zipcode', 'yes']
    ]
    prerequisite_checker(infos)
  end


  def affiliation_with_prerequisites
    infos = [
      ['has_hospital_privilege', 'hp-facility-name', 'yes'],
      ['has_hospital_privilege', 'hp-mso-address-line1', 'yes'],
      ['has_hospital_privilege', 'hp-city', 'yes'],
      ['has_hospital_privilege', 'hp-mso-telephone-number', 'yes'],
      ['has_hospital_privilege', 'hp-zipcode', 'yes'],
      ['has_hospital_privilege', 'hp-mso-fax-number', 'yes'],
      ['has_admitting_arrangement','state_abbr','yes'],
      ['has_admitting_arrangement','facility-name','yes'],
      ['has_admitting_arrangement','facility-address-line1','yes'],
      ['has_admitting_arrangement','facility-zipcode','yes'],
    ]
    prerequisite_checker(infos)
  end

  def professional_liability_with_prerequisites
    infos = [
      ['is_self_insured', 'lf-carrier-location', 'no'],
      ['is_self_insured', 'lf-carrier-name', 'no'],
      ['is_self_insured', 'lf-address-line1', 'no'],
      ['is_self_insured', 'lf-city', 'no'],
      ['is_self_insured', 'lf-zipcode', 'no'],
      ['is_self_insured', 'lf-policy-number', 'no'],
      ['is_self_insured', 'lf-self-insured-policy-name', 'yes'],
      ['is_self_insured', 'lf-self-insured-policy-number', 'yes'],
      ['is_self_insured', 'lf-self-insured-carrier-name', 'yes'],
      ['is_self_insured', 'lf-self-insured-coverage-amount', 'yes'],
      ['is_self_insured', 'lf-self-insured-email-aggregate-coverage', 'yes'],
      ['is_self_insured', 'lf-self-insured-original-effective-date', 'yes'],
      ['is_self_insured', 'lf-self-insured-original-expiration-date', 'yes']
    ]
    prerequisite_checker(infos)
  end

  def military_info_with_prerequisites
    infos = [
      ['served_in_military', 'military_enlist_base_of_service', 'yes']
    ]
    prerequisite_checker(infos)
  end

  def employment_with_prerequisites
    infos = [
      ['has_work_history', 'edc-employment-location', 'yes'],
      ['has_work_history', 'edc-practice-employer-name', 'yes'],
      ['has_work_history', 'edc-address-line1', 'yes'],
      ['has_work_history', 'edc-city', 'yes'],
      ['has_work_history', 'edc-zipcode', 'yes'],
      ['has_work_history', 'edc-telephone-number', 'yes'],
      ['has_work_history', 'edc-fax-number', 'yes'],
      ['has_work_history', 'edc-email', 'yes'],
      ['has_work_history', 'edc-contact-method', 'yes'],
      ['has_work_history', 'edc-start-date', 'yes'],
      ['has_work_history', 'edc-end-date', 'yes'],
      ['has_collab_agreement', '', 'yes'],
    ]
    prerequisite_checker(infos)
  end

  def employment_gap_with_prerequisites
    infos = [
      ['has_employment_gap','gap_start_date','yes'],
      ['has_employment_gap','gap_end_date','yes'],
      ['has_employment_gap','gap_reason','yes'],
      ['has_employment_gap','gap_explanation','yes'],
    ]
    prerequisite_checker(infos)
  end

  def professional_organization_with_prerequisites
    infos = [
      ['belonged_to_prog_org', 'prof_organization_name','yes']
    ]
    prerequisite_checker(infos)
  end

  def disclosures_with_prerequisites
    infos = []
    DisclosureQuestion.all.each do |d|
      infos << [d.slug, "#{d.slug}_explanation", 'yes']
    end
    prerequisite_checker(infos)
    # infos
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

  def add_to_roster group_engage_provider
		['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn'].each	do |column|
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

  private

  # will set provider source disclosure answer to no as default is needed to calculate percentage of progress
  def set_default_disclosure_answer
    DisclosureQuestion.all.each do |question|
      ProviderSourceData.find_or_create_by(provider_source_id: self.id, data_key: question.slug, data_value: 'no')
    end
  end

  def delete_group_engage_provider
    group_engage_provider.destroy if group_engage_provider.present?
  end
end