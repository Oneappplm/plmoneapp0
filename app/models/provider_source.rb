class ProviderSource < ApplicationRecord
  has_many :data, class_name: 'ProviderSourceData', inverse_of: :provider_source, dependent: :destroy
  has_many  :documents, class_name: 'ProviderSourceDocument', inverse_of: :provider_source, dependent: :destroy
  has_many :deas, class_name: 'ProviderSourcesDea', inverse_of: :provider_source, dependent: :destroy
  has_many :cds, class_name: 'ProviderSourcesCds', inverse_of: :provider_source, dependent: :destroy
  has_many :cmes, class_name: 'ProviderSourceCme', inverse_of: :provider_source, dependent: :destroy
  has_many :licensures, class_name: 'ProviderSourceLicensure', inverse_of: :provider_source, dependent: :destroy
  has_many :registrations, class_name: 'ProviderSourcesRegistration', inverse_of: :provider_source, dependent: :destroy

  has_many :other_names, dependent: :destroy
  accepts_nested_attributes_for :other_names, allow_destroy: true

  has_many :provider_source_specialities, dependent: :destroy
  accepts_nested_attributes_for :provider_source_specialities, allow_destroy: true

  has_many :provider_source_undergrad_schools, dependent: :destroy
  accepts_nested_attributes_for :provider_source_undergrad_schools, allow_destroy: true

  has_many :graduate_details, dependent: :destroy
  accepts_nested_attributes_for :graduate_details, allow_destroy: true

  has_many :admitting_arrangements, dependent: :destroy
  accepts_nested_attributes_for :admitting_arrangements, allow_destroy: true

  has_many :hospital_privileges, dependent: :destroy
  accepts_nested_attributes_for :hospital_privileges, allow_destroy: true


  accepts_nested_attributes_for :deas, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :cds, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :registrations, allow_destroy: true, reject_if: :all_blank


  belongs_to :practice_location, optional: true
  belongs_to :group_engage_provider, optional: true
  scope :current, ->{ find_by(current_provider_source: true) }
  # this will make it so that every user will have a different current provider source on the provider engage page
  scope :current_provider_source_by_current_user, ->(user_id) { find_by(created_by_user: user_id, current_provider_source: true) }
  default_scope { order(current_provider_source: :desc) }
  belongs_to :provider_personal_information
  
  delegate :first_name, :last_name, :middle_name, :suffix,
         to: :provider_personal_information,
         allow_nil: true

  # licenses type
  LICENSE_TYPE = 
  [
    "Acupuncturist",
    "Advance Practice Nurses",
    "Alcohol/Drug Counselor",
    "Athletic Trainer",
    "Audiologist",
    "Biofeedback Technician",
    "Board Certified Assistant Behavioral Analyst",
    "Board Certified Behavioral Analyst",
    "Case Manager",
    "Certified Dental Assistant",
    "Certified Occupational Therapist Assistant",
    "Certified Registered Nurse Anesthetist",
    "Christian Science Practitioner",
    "Clinical Lab Scientist",
    "Clinical Nurse Specialist",
    "Clinical Social Worker",
    "Dental Assistant",
    "Dental Hygienist",
    "Dietician",
    "Doctor of Chiropractic (DC)",
    "Doctor of Dental Medicine (DMD)",
    "Doctor of Dental Surgery (DDS)",
    "Doctor of Education",
    "Doctor of Podiatric Medicine (DPM)",
    "Licensed Bachelors Social Worker",
    "Licensed Clinical Laboratory Technologist",
    "Licensed Clinical Social Worker",
    "Licensed Marriage/Family Therapist",
    "Licensed Massage Therapist",
    "Licensed Masters Social Worker",
    "Licensed Medical Esthetician",
    "Licensed Mental Health Counselor",
    "Licensed Practical Nurse",
    "Licensed Professional Counselor",
    "Licensed Vocational Nurse",
    "Limited License Masters Social Worker",
    "Limited Social Service Technician",
    "Marriage/Family Therapist",
    "Medical Assistant",
    "Medical Doctor (MD)",
    "Neuropsychologist",
    "Occupational Therapist",
    "Orthopedic Technologist",
    "Pastoral Counselor",
    "PhD, Doctor of Philosophy",
    "Phlebotomist",
    "Physical Therapist",
    "Physical Therapist Assistant",
    "Professional Counselor",
    "Psychologist",
    "Qualified Behavioral Health Professional",
    "Recreational Therapist",
    "Registered Dental Assistant",
    "Registered Medical Assistant",
    "Spectacle Lens Dispenser",
    "Social Service Technician",
    "Social Worker",
    "Speech-Language Pathologist",
    "Substance Abuse Prevention Specialist",
    "Substance Abuse Treatment Specialist",
    "Surgical Technologist",
    "Temporary Limited License Psychologist"
  ].freeze

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

  # after_create :set_default_disclosure_answer
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

  def full_address
    [
      fetch("cc-address-line1"),
      fetch("cc-address_line2"),
      fetch("cc-city"),
      fetch("cc-state"),
      fetch("cc-zip")
    ].compact.join(", ")
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

  def is_answer_no?(question_slug)
    # this is for disclosures related models is DisclosureQuestion and ProviderSourceData
    fetch(question_slug) == 'no'
  end

  def no_answer?(question_slug)
    # this is for disclosures related models is DisclosureQuestion and ProviderSourceData
    fetch(question_slug).nil?
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

    # Base fields
    fields_no_prerequisites = [
      'first_name', 'last_name', 'degree_titles',
      'state_of_practice', 'primary-practioner-type',
      'gi-country', 'address_line_1', 'city', 'ps-state',
      'telephone', 'email_address', 'zipcode'
    ]

    # Count base field completions
    filled_up_fields = fetch_many(fields_no_prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    total_fields_count = fields_no_prerequisites.count
    total_filled_fields = filled_up_fields

    # Include nested form: Other Names
    other_name_lists = other_names # or adjust if provider_source is not scoped
    other_name_required_fields = %w[first_name last_name]

    other_name_lists.each do |on|
      other_name_required_fields.each do |field|
        total_fields_count += 1
        value = on.send(field)
        total_filled_fields += 1 if value.present?
      end
    end

    if total_fields_count.positive?
      percentage = ((total_filled_fields.to_f / total_fields_count.to_f) * 100).round
    end

    percentage
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
    # prereq keys stored in provider_source_data
    prereq_keys = %w[has_dea_registration_number has_cds_registration_number registration_id_form]
    prereq_data = data.where(data_key: prereq_keys).pluck(:data_key, :data_value).to_h.transform_values { |v| v.to_s.strip.downcase }

    # Count how many prereqs have an explicit value (non-blank)
    answered_prereqs = prereq_data.values.reject(&:blank?).count

    # If user explicitly said "no" to all and there are no records at all, return 100
    if prereq_data.values.all? { |v| v != 'yes' } && deas.blank? && cds.blank? && registrations.blank?
      Rails.logger.debug(">>> registration_ids_progress: all prereqs not 'yes' and no records exist -> returning 100")
      return 100
    end

    total_nested = 0
    answered_nested = 0

    # Helper to check presence (treats nil, '', whitespace as blank)
    present_value = ->(val) { val.present? && val.to_s.strip.downcase != 'nil' }

    # ===== DEA SECTION =====
    has_dea = prereq_data['has_dea_registration_number'] == 'yes'
    if has_dea
      dea_required_fields = %w[registration_number issue_date expiration_date state]

      if deas.any?
        # Count fields per record
        deas.each do |d|
          dea_required_fields.each do |field|
            total_nested += 1
            val = (d.respond_to?(field) ? d.send(field) : nil) rescue nil
            answered_nested += 1 if present_value.call(val)
          end
        end
      else
        # No DEA records exist but user said yes -> treat as required fields unanswered
        total_nested += dea_required_fields.size
        Rails.logger.debug(">>> DEA: flag=yes but no DEA records -> counting #{dea_required_fields.size} required fields as unanswered")
      end
    end

    # ===== CDS SECTION =====
    has_cds = prereq_data['has_cds_registration_number'] == 'yes'
    if has_cds
      cds_required_fields = %w[registration_number issue_date expiration_date state]

      if cds.any?
        cds.each do |c|
          cds_required_fields.each do |field|
            total_nested += 1
            val = (c.respond_to?(field) ? c.send(field) : nil) rescue nil
            answered_nested += 1 if present_value.call(val)
          end
        end
      else
        total_nested += cds_required_fields.size
        Rails.logger.debug(">>> CDS: flag=yes but no CDS records -> counting #{cds_required_fields.size} required fields as unanswered")
      end
    end

    # ===== REGISTRATION (State / Other) SECTION =====
    has_registration = prereq_data['registration_id_form'] == 'yes'
    if has_registration
      registration_required_fields = %w[
        registration_number specialty issuing_board zip_code address_line_1
        issue_date registration_state issue_state expiration_date practicing_under_number
      ]

      if registrations.any?
        registrations.each do |r|
          registration_required_fields.each do |field|
            total_nested += 1
            val = (r.respond_to?(field) ? r.send(field) : nil) rescue nil
            answered_nested += 1 if present_value.call(val)
          end
        end
      else
        total_nested += registration_required_fields.size
        Rails.logger.debug(">>> Registration: flag=yes but no registration records -> counting #{registration_required_fields.size} required fields as unanswered")
      end
    end

    total_fields = prereq_keys.size + total_nested
    total_answered = answered_prereqs + answered_nested

    progress = if total_fields.positive?
                 ((total_answered.to_f / total_fields.to_f) * 100).round
               else
                 0
               end

    Rails.logger.debug(
      ">>> registration_ids_progress: prereq_values=#{prereq_data.inspect}, " \
      "answered_prereqs=#{answered_prereqs}, answered_nested=#{answered_nested}, " \
      "total_nested=#{total_nested}, total_fields=#{total_fields}, progress=#{progress}"
    )

    progress
  rescue => e
    Rails.logger.error("registration_ids_progress error: #{e.message}\n#{e.backtrace.join("\n")}")
    0
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
    prerequisites = ['medicare_field', 'medicaid_field', 'caqh_field', 'other_cert_field']
    with_prerequisites = [
      :other_ids_certifications_progress_medicare_fields,
      :other_ids_certifications_progress_medicaid_fields,
      :other_ids_certifications_progress_caqh_fields,
      :other_ids_certifications_progress_other_fields
    ]

    # Fetch prerequisite yes/no values
    prereq_values = Hash[
      fetch_many(prerequisites)&.pluck(:data_key, :data_value) || []
    ]

    fields_to_answer = []
    prerequisites.each_with_index do |field, idx|
      # Always require the prerequisite yes/no question itself
      fields_to_answer << field

      # Only require extra fields if answer is YES
      if prereq_values[field].to_s.strip.downcase == 'yes'
        fields_to_answer.concat(send(with_prerequisites[idx]))
      end
    end

    # Get actual values for all required fields
    fetched_values = Hash[
      fetch_many(fields_to_answer)&.pluck(:data_key, :data_value) || []
    ]

    # Missing fields list
    missing_fields = fields_to_answer.select do |field|
      value = fetched_values[field]
      value.blank? || value.to_s.strip == ''
    end

    answered_count = fields_to_answer.size - missing_fields.size
    percentage = (answered_count.to_f / fields_to_answer.size) * 100

    { percentage: percentage.to_i, missing_fields: missing_fields }
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
    specialties = provider_source_specialities

    always_required_fields = %w[
      speciality_ranking speciality board_certified eligible_certified
    ]

    total_specialty_fields = 0
    answered_specialty_fields = 0

    # Treat both true and false as answered
    answered = ->(val) { val.present? || val == false }

    # --- 1️⃣ Include student intern field (stored in provider_source_data) ---
    student_intern_value = data.find_by(data_key: 'specialty_student_intern')&.data_value

    total_specialty_fields += 1
    answered_specialty_fields += 1 if answered.call(student_intern_value)

    # --- 2️⃣ Handle nested specialties ---
    specialties.each do |spec|
      # Always-required fields
      always_required_fields.each do |field|
        total_specialty_fields += 1
        answered_specialty_fields += 1 if answered.call(spec.send(field))
      end

      certified = spec.board_certified
      eligible = spec.eligible_certified
      pending = spec.board_exam_results_pending
      applied = spec.applied_for_certification_exam
      accepted = spec.accepted_for_certification_exam
      intend = spec.intend_applied_for_certification_exam

      if certified == true
        %w[
          certifying_board address_line_1 address_line_2 city state zipcode telephone
        ].each do |field|
          total_specialty_fields += 1
          answered_specialty_fields += 1 if spec.send(field).present?
        end

      elsif certified == false && eligible == true
        total_specialty_fields += 1
        answered_specialty_fields += 1 if answered.call(pending)

        if pending == true
          %w[pending_address_line_1 pending_city pending_zipcode pending_state].each do |field|
            total_specialty_fields += 1
            answered_specialty_fields += 1 if spec.send(field).present?
          end

        elsif pending == false
          total_specialty_fields += 1
          answered_specialty_fields += 1 if answered.call(applied)

          if applied == true
            total_specialty_fields += 1
            answered_specialty_fields += 1 if answered.call(accepted)

            if accepted == true
              total_specialty_fields += 1
              answered_specialty_fields += 1 if spec.board_exam_date.present?
            end

          elsif applied == false
            total_specialty_fields += 1
            answered_specialty_fields += 1 if answered.call(intend)

            if intend == true
              total_specialty_fields += 1
              answered_specialty_fields += 1 if spec.intend_date_apply.present?
            elsif intend == false
              total_specialty_fields += 1
              answered_specialty_fields += 1 if spec.specialties_no_board_exam_reason.present?
            end
          end
        end
      end
    end

    # --- 3️⃣ Compute percentage ---
    if total_specialty_fields.positive?
      percentage = ((answered_specialty_fields.to_f / total_specialty_fields) * 100).round
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
    prerequisites = ['undergraduate_school', 'professional_school']
    values = fetch_many(prerequisites)&.pluck(:data_value) || []

    # If both toggles are 'no' or nil, return 100%
    return 100 unless values.include?('yes')

    answered_prereqs = fetch_many(prerequisites)
                          &.pluck(:data_value)
                          .compact
                          .reject(&:empty?)
                          .count

    undergrad_model_fields = %w[
      school_location undergraduate_school_name address_line1 city zipcode degree_awarded incomplete date_graduation
    ]

    graduate_model_fields = %w[
      location professional_school_name address_line1 zip_code degree_awarded city start_date graduation_date
    ]

    total_nested_fields = 0
    answered_nested_fields = 0

    # Undergraduate school section
    if values[0] == 'yes'
      if provider_source_undergrad_schools.any? { |s| s.id.present? }
        provider_source_undergrad_schools.each do |school|
          undergrad_model_fields.each do |field|
            total_nested_fields += 1
            value = school.send(field)
            answered_nested_fields += 1 unless value.nil? || value.to_s.strip == ''
          end
        end
      else
        # No record, but still count fields as required
        total_nested_fields += undergrad_model_fields.size
      end
    end

    # Graduate school section
    if values[1] == 'yes'
      if graduate_details.any? { |g| g.id.present? }
        graduate_details.each do |grad|
          graduate_model_fields.each do |field|
            total_nested_fields += 1
            value = grad.send(field)
            answered_nested_fields += 1 unless value.nil? || value.to_s.strip == ''
          end
        end
      else
        # No record, but still count fields as required
        total_nested_fields += graduate_model_fields.size
      end
    end

    total_fields = prerequisites.count + total_nested_fields
    total_answered = answered_prereqs + answered_nested_fields

    if total_fields.positive?
      ((total_answered.to_f / total_fields) * 100).round
    else
      100
    end
  end

  # def education_undergrad_fields
  #   [
  #     'provider_source_undergrad_schools[0][school_location]', 'provider_source_undergrad_schools[0][undergraduate_school_name]',
  #     'provider_source_undergrad_schools[0][address_line1]', 'provider_source_undergrad_schools[0][city]', 'provider_source_undergrad_schools[0][zipcode]', 'provider_source_undergrad_schools[0][degree_awarded]',
  #     'provider_source_undergrad_schools[0][incomplete]', 'provider_source_undergrad_schools[0][date_graduation]'
  #   ]
  # end

  # def education_graduate_fields
  #   [
  #     'graduate_details[0][location]', 'graduate_details[0][professional_school_name]', 'graduate_details[0][address_line1]', 'graduate_details[0][zip_code]',
  #     'graduate_details[0][degree_awarded]', 'graduate_details[0][city]', 'graduate_details[0][start_date]', 'graduate_details[0][graduation_date]'
  #   ]
  # end

  def training_progress_v2
    prerequisites = ['has_training_program']
    with_prerequisites = ['training_has_training_program_fields']
    values = fetch_many(prerequisites)&.pluck(:data_value) || []

    percentage = if values.include?('yes')
      prerequisites_with_yes = values.map.with_index { |v, idx| idx if v == 'yes' }.compact
      fields_to_fill_up = prerequisites_with_yes.map { |y| send(with_prerequisites[y]) }

      # Do NOT delete prerequisites from count — keep them in total
      fields_to_answer = prerequisites + fields_to_fill_up.flatten
      answered = fetch_many(fields_to_answer)&.pluck(:data_value).compact.reject(&:empty?).count

      ((answered.to_f / fields_to_answer.count) * 100)
    else
      100
    end

    percentage.round
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
    # normalize fetch safely so missing keys don't blow up
    cme_credit = begin self.fetch('cme_credit') rescue nil end
    normalized = cme_credit.to_s.strip.downcase

    # if user explicitly answered "no" (or variants) => 100% immediately
    return 100 if %w[no false 0].include?(normalized)

    # collect all CME field values (may be empty array)
    total_cme_values = begin
      (self.cmes.pluck(:training, :month_attended, :year_attended, :hours) || []).flatten
    rescue
      []
    end

    # count total fields and answered fields
    total_fields = total_cme_values.count
    answered = total_cme_values.reject { |v| v.nil? || v.to_s.strip == '' }.count

    # include credentials field if present (optional)
    credentials = begin self.fetch('cme_requested_credentials') rescue nil end
    if credentials.present?
      total_fields += 1
      answered += 1
    end

    # if user answered "yes", compute percentage (0 if there are no required fields)
    if normalized == 'yes'
      return 0 if total_fields.zero?
      return ((answered.to_f / total_fields.to_f) * 100).to_i
    end

    # fallback: if credentials supplied treat as complete, otherwise 0
    credentials.present? ? 100 : 0
  rescue
    0
  end

  def affiliation_info_progress
    prerequisites = ['has_admitting_arrangement', 'has_hospital_privilege']
    values = fetch_many(prerequisites)&.pluck(:data_value).map { |v| v.to_s.strip.downcase }

    # If both toggles are 'no' or blank → 100%
    return 100 if values.all? { |v| v.blank? || v == 'no' }

    # Count answered prerequisite toggles
    answered_prerequisites = fetch_many(prerequisites)&.pluck(:data_value).compact.reject(&:empty?).count

    # Fields for each nested model
    hospital_fields = %w[
      state_abbr hp_facility_name hp_mso_address_line1 hp_city hp_zipcode
      hp_mso_telephone_number hp_mso_fax_number hp_department_name
    ]
    arrangement_fields = %w[
      admit_state facility_name facility_address_line1 facility_zipcode
    ]

    total_nested_fields = 0
    answered_nested_fields = 0

    # Hospital privilege section
    if values[1] == 'yes'
      if hospital_privileges.any?
        hospital_privileges.each do |hp|
          hospital_fields.each do |field|
            total_nested_fields += 1
            answered_nested_fields += 1 if hp.send(field).present?
          end
        end
      else
        total_nested_fields += hospital_fields.size
      end
    end

    # Admitting arrangement section
    if values[0] == 'yes'
      if admitting_arrangements.any?
        admitting_arrangements.each do |aa|
          arrangement_fields.each do |field|
            total_nested_fields += 1
            answered_nested_fields += 1 if aa.send(field).present?
          end
        end
      else
        total_nested_fields += arrangement_fields.size
      end
    end

    total_fields = prerequisites.size + total_nested_fields
    total_answered = answered_prerequisites + answered_nested_fields

    return ((total_answered.to_f / total_fields) * 100).round if total_fields.positive?
    100
  end


  def affiliation_info_completed?
    ![affiliation_info_progress].any?{|e| e != 100}
  rescue
    false
  end

  def professional_liability_progress_v2
    # The prerequisite question
    prerequisites = ['has_sovereign_immunity']
    values = fetch_many(prerequisites)&.pluck(:data_value).map { |v| v.to_s.strip.downcase }

    # If 'has_sovereign_immunity' is 'no' or blank → 100% progress
    return 100 if values.blank? || values.first == 'no'

    # Otherwise, check if self-insured or not
    insured = fetch('is_self_insured').to_s.strip.downcase
    fields_to_fill_up = insured == 'yes' ? self_insured_yes_fields : self_insured_no_fields

    # Add the prerequisite toggle itself to the list of fields to answer
    fields_to_answer = prerequisites + fields_to_fill_up

    answered_count = fetch_many(fields_to_answer)
      &.pluck(:data_value)
      .compact
      .reject(&:empty?)
      .count

    total_fields = fields_to_answer.count
    return ((answered_count.to_f / total_fields) * 100).round if total_fields.positive?

    100
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
    prerequisites = ['has_work_history']
    values = fetch_many(prerequisites)&.pluck(:data_value).map { |v| v.to_s.strip.downcase } rescue []

    return 100 if values.blank? || values.first == 'no'

    fields = work_history_employment_fields
    fetched = fetch_many(fields)&.pluck(:data_value) || []

    # Only count fields that actually exist in fetched results
    total_fields = fetched.size
    answered_count = fetched.reject { |v| v.nil? || v.to_s.strip.empty? }.count

    return 100 if total_fields.zero?

    ((answered_count.to_f / total_fields) * 100).round
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
    fields_to_fill_up = ['all_practice_location']

    fields_to_fill_up += practice_location_general_information_fields if practice_location_general_info_started?
    fields_to_fill_up += practice_location_contacts_fields if practice_location_contacts_started?
    fields_to_fill_up += practice_location_midlevel_practitioner_fields if practice_location_midlevel_practitioner_started?
    fields_to_fill_up += practice_location_partners_fields if practice_location_partners_started?

    # Fetch existing values into a hash
    existing = fetch_many(fields_to_fill_up)&.pluck(:data_key, :data_value).to_h

    # Normalize each field
    normalized = fields_to_fill_up.index_with do |key|
      val = existing[key]

      # Ensure we trim whitespace
      val = val.strip if val.is_a?(String)

      # Count only non-blank, non-nil values as answered
      val.present? ? val : nil
    end

    answered_count = normalized.values.count { |v| v.present? }
    total_fields   = fields_to_fill_up.size

    percentage = if total_fields.zero?
      100
    else
      (answered_count.to_f / total_fields) * 100
    end

    percentage.round
  end



  def practice_location_general_information_fields
    [
      'practice_name', 'practice_address_line_1', 'practice_city',
      'dco_state', 'practice_zip_code', 'practice_telephone_number',
      'practice_type', 'practice_type_tax_id', 'group_npi_field'
    ]
  end

  def practice_location_contacts_fields
    [
      'contact_office_first_name', 'contact_office_last_name', 'contact_office_address_line_1',
      'contact_office_city', 'contact_office_state', 'contact_office_zip_code', 'contact_office_telephone_number',
      'contact_billing_address_line_1','contact_billing_city', 'contact_billing_state', 'contact_billing_zip_code',
      'contact_billing_telephone_number'
    ]
  end

  def practice_location_midlevel_practitioner_fields
    [ 'practice_midlevel_first_name', 'practice_midlevel_last_name', 'practice_midlevel_degree' ]
  end

  def practice_location_partners_fields
    [
      'practice_partners_first_name', 'practice_partners_last_name', 'practice_partners_degree', 'practice_partners_specialty'
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
    prerequisites = DisclosureQuestion.all.order(:slug).pluck(:slug)
    with_prerequisites = prerequisites.map{|m| "#{m}_explanation"}
    values = fetch_many(prerequisites).order(:data_key)&.pluck(:data_key, :data_value)
    data_values = values.collect { |c| c[1] }
    valid_yes_count = if data_values.include?('yes')
      prerequisites_with_yes = values.select { |v| v[1] == 'yes' }
      prerequisites_with_yes = prerequisites_with_yes.map{|m| "#{m[0]}_explanation"}
      answered = fetch_many(prerequisites_with_yes)&.pluck(:data_value).compact.reject(&:empty?).count
      answered
    else
      0
    end

    no_count = data_values.select{|v| v == 'no'}.count
    percentage = ((valid_yes_count + no_count) / with_prerequisites.count.to_f) * 100
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

  def all_sections_completed?
    general_info_completed? &&
      professional_ids_completed? &&
      health_plans_completed? &&
      speacialties_completed? &&
      education_and_training_completed? &&
      affiliation_info_completed? &&
      professional_liability_completed? &&
      work_history_completed? &&
      medical_education_progress == 100
      disclosure_progress_v2 == 100 &&
      practice_information_completed? &&
      self.documents.present?
  end

  private

  # will set provider source disclosure answer to no as default is needed to calculate percentage of progress
  # def set_default_disclosure_answer
  #   DisclosureQuestion.all.each do |question|
  #     ProviderSourceData.find_or_create_by(provider_source_id: self.id, data_key: question.slug, data_value: 'no')
  #   end
  # end

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
