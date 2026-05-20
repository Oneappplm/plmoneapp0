# app/services/provider_excel_import_service.rb
# frozen_string_literal: true

require "roo"

class ProviderExcelImportService
  def initialize(file:, enrollment_group_id: nil, admin_id: nil)
    @file = file
    @enrollment_group_id = enrollment_group_id
    @admin_id = admin_id
    @errors = []
    @success_count = 0
  end

  def call
    xlsx = Roo::Excelx.new(file_path)

    Rails.logger.info "Excel sheets: #{xlsx.sheets.inspect}"

    provider_xlsx = Roo::Excelx.new(file_path)
    provider_xlsx.default_sheet = "Provider Data"

    enrollment_xlsx = Roo::Excelx.new(file_path)
    enrollment_xlsx.default_sheet = "Enrollment Data"
    import_provider_data(provider_xlsx)
    import_enrollment_data(enrollment_xlsx)

    {
      success_count: @success_count,
      errors: @errors
    }
  end

  private

  # ============================================================
  # Provider Data tab
  # ============================================================

  def import_provider_data(sheet)
    header_row = detect_header_row(
      sheet,
      ["first_name", "last_name", "ssn", "date_of_birth", "npi_number"]
    )

    headers = normalized_headers(sheet, header_row)

    Rails.logger.info "Provider import sheet: Provider Data"
    Rails.logger.info "Provider import header row: #{header_row}"
    Rails.logger.info "Provider import headers: #{headers.inspect}"

    ((header_row + 1)..sheet.last_row).each do |row_number|
      row = row_hash(sheet, headers, row_number)
      next if blank_row?(row)

      Provider.transaction do
        provider = create_or_update_provider!(row)

        create_provider_license!(provider, row)
        create_np_license!(provider, row)
        create_rn_license!(provider, row)
        create_pa_license!(provider, row)
        create_dea_license!(provider, row)
        create_cds_license!(provider, row)
        create_board_certification!(provider, row)
        create_ins_policy!(provider, row)
        create_service_location!(provider, row)
        create_medicaid!(provider, row)
        create_medicare!(provider, row)

        @success_count += 1
      end
    rescue => e
      Rails.logger.error "PROVIDER ROW #{row_number} FAILED"
      Rails.logger.error e.message

      @errors << {
        sheet: "Provider Data",
        row: row_number,
        error: e.message
      }
    end
  end

  def create_or_update_provider!(row)
    attrs = provider_attributes(row)

    if attrs[:first_name].blank? || attrs[:last_name].blank?
      raise "Provider first name/last name missing. Check Provider Data tab headers."
    end

    provider = find_existing_provider(row) || Provider.new
    provider.assign_attributes(attrs)
    provider.save!

    provider
  end

  def provider_attributes(row)
    group = default_enrollment_group

    {
      first_name: pick(row, "first_name"),
      middle_name: pick(row, "middle_name"),
      last_name: pick(row, "last_name"),
      suffix: pick(row, "suffix"),
      gender: pick(row, "gender"),

      ssn: pick(row, "ssn", "social_security_number"),
      birth_date: date(pick(row, "date_of_birth", "birth_date", "dob")),
      birth_city: pick(row, "birth_city"),
      birth_state: state_alpha_or_value(pick(row, "birth_state")),

      address_line_1: pick(row, "address_line_1", "address1", "address"),
      address_line_2: pick(row, "address_line_2", "address2", "suite"),
      city: pick(row, "city"),
      state_id: state_id(pick(row, "state")),
      zip_code: pick(row, "zipcode_4_zip_code", "zip_code", "zipcode"),

      telephone_number: pick(row, "telephone_number", "phone_number"),
      ext: pick(row, "extention", "extension", "ext"),
      email_address: pick(row, "email", "email_address"),

      practitioner_type: pick(row, "practitioner_type_can_be_multiple", "practitioner_type", "provider_type"),
      taxonomy: pick(row, "taxonomy", "taxonomy_code"),
      specialty: pick(row, "specialty_i_e_specialties_is_selected_based_on_taxonomy_codes_can_be_multiple", "specialty", "specialties"),

      provider_effective_date: date(pick(row, "provider_effective_date")),
      npi: pick(row, "npi_number", "npi"),

      caqh_id: pick(row, "caqh_id"),
      caqhid: pick(row, "caqh_id", "caqhid"),
      caqh_username: pick(row, "caqh_username"),
      caqh_password: pick(row, "caqh_password"),
      caqh_state: state_alpha_or_value(pick(row, "caqh_state")),
      caqh_current_reattestation_date: pick(row, "current_re_attestation"),
      caqh_reattest_completed_by: pick(row, "re_attestation_must_be_completed_by"),

      medical_school_name: pick(row, "name_of_u_s_canadian_school", "medical_school_name"),
      medical_school_address: pick(row, "medical_school_address"),
      graduation_date: date(pick(row, "end_date", "graduation_date")),
      prof_medical_school_name: pick(row, "name_of_u_s_canadian_school", "medical_school_name"),
      prof_medical_school_address: pick(row, "medical_school_address"),
      prof_medical_school_city: pick(row, "medical_school_city"),
      prof_medical_school_state_id: state_id(pick(row, "medical_school_state")),
      prof_medical_school_country: pick(row, "medical_school_country"),
      prof_medical_school_zipcode: pick(row, "medical_school_zipcode"),
      prof_medical_start_date: date(pick(row, "start_date")),
      prof_medical_school_degree_awarded: pick(row, "degree_awarded"),
      medical_license: pick(row, "did_you_complete_your_graduate_education_at_this_school"),

      # Some of these columns exist directly on providers too.
      license_number: pick(row, "state_license_number", "license_number"),
      license_effective_date: date(pick(row, "state_license_effective_date", "state_license_renewal_current_effective_date")),
      license_expiration_date: date(pick(row, "state_license_expiration_date")),
      license_state_id: state_id(pick(row, "state_registered", "license_state", "state")),
      license_state_number: pick(row, "state_license_number", "license_number"),
      license_state_effective_date: date(pick(row, "state_license_effective_date", "state_license_renewal_current_effective_date")),
      license_state_expiration_date: date(pick(row, "state_license_expiration_date")),

      np_license_number: pick(row, "np_license_number"),
      np_license_effective_date: date(pick(row, "np_license_effective_date")),
      np_license_expiration_date: date(pick(row, "np_license_expiration_date")),

      rn_license_number: pick(row, "rn_license_number"),
      rn_license_effective_date: date(pick(row, "rn_license_effective_date", "rn_license_renewal_current_effective_date")),
      rn_license_expiration_date: date(pick(row, "rn_license_expiration_date")),

      pa_license_number: pick(row, "pa_license_number"),
      pa_license_effective_date: date(pick(row, "pa_license_effective_date")),
      pa_license_expiration_date: date(pick(row, "pa_license_expiration_date")),

      dea_number: pick(row, "dea_registration_number", "dea_number", "dea_license_number"),
      dea_registration_state: pick(row, "dea_registration_state"),
      dea_license_effective_date: pick(row, "dea_registration_original_license_issue_date"),
      dea_license_expiration_date: date(pick(row, "dea_registration_expiration_date", "dea_license_expiration_date")),

      board_name: pick(row, "board_name"),
      board_certificate_number: pick(row, "certification_number", "board_certificate_number"),
      board_effective_date: date(pick(row, "board_effective_date", "effective_date")),
      board_recertification_date: date(pick(row, "re_certification_date", "board_recertification_date")),
      board_expiration_date: date(pick(row, "board_expiration_date", "expiration_date")),
      board_specialty_type: pick(row, "specialty_type", "board_specialty_type"),

      prof_liability_carrier_name: pick(row, "carrier_or_self_insured_name", "prof_liability_carrier_name"),
      prof_liability_self_insured: pick(row, "self_insured"),
      prof_liability_address: pick(row, "liability_address", "address"),
      prof_liability_city: pick(row, "liability_city"),
      prof_liability_state_id: state_id(pick(row, "liability_state", "state")),
      prof_liability_zipcode: pick(row, "liability_zip_code", "zip_code_4_zip_code", "zip_code"),
      prof_liability_orig_effective_date: date(pick(row, "original_effective_date")),
      prof_liability_effective_date: date(pick(row, "liability_effective_date", "effective_date")),
      prof_liability_expiration_date: date(pick(row, "liability_expiration_date", "expiration_date")),
      prof_liability_coverage_type: pick(row, "type_of_coverage"),
      prof_liability_policy_number: pick(row, "policy_number"),
      prof_liability_coverage_amount_aggregate: pick(row, "amount_of_coverage_aggregate"),
      prof_liability_coverage_amount: pick(row, "amount_of_coverage_per_occurence"),
      prof_liability_tail_coverage: pick(row, "policy_includes_tail_coverage?"),
      prof_liability_unlimited_coverage: pick(row, "do_you_have_unlimited_coverage"),
      policy_number: pick(row, "policy_number"),

      medicare: pick(row, "medicare_provider_number", "medicare_number", "medicare"),
      medicare_provider_number: pick(row, "medicare_provider_number", "medicare_number", "medicare"),
      medicare_revalidation_date: date(pick(row, "medicare_revalidation_date")),

      medicaid: pick(row, "medicaid_provider_number", "medicaid_number", "medicaid"),
      medicaid_provider_number: pick(row, "medicaid_provider_number", "medicaid_number", "medicaid"),
      medicaid_revalidation_date: date(pick(row, "medicaid_revalidation_date")),

      practice_location_name: pick(row, "practice_location_name", "facility_name", "primary_service_location_apps"),

      enrollment_group_id: group.id,
      status: pick(row, "status").presence || "active"
    }.compact
  end

  def find_existing_provider(row)
    first_name = pick(row, "first_name")
    middle_name = pick(row, "middle_name")
    last_name = pick(row, "last_name")
    birth_date = date(pick(row, "date_of_birth", "birth_date", "dob"))
    caqh_id = pick(row, "caqh_id", "caqhid")
    npi = pick(row, "npi_number", "npi")
    ssn = pick(row, "ssn", "social_security_number")

    # 1. Strongest match: NPI
    return Provider.find_by(npi: npi) if npi.present?

    # 2. Strong match: SSN
    return Provider.find_by(ssn: ssn) if ssn.present?

    return nil if first_name.blank? || last_name.blank?

    # 3. Requested duplicate prevention:
    # same first name + last name + CAQH ID should update, not create.
    if caqh_id.present?
      provider = Provider.where(
        "LOWER(first_name) = ? AND LOWER(last_name) = ? AND (caqh_id = ? OR caqhid = ?)",
        first_name.to_s.downcase,
        last_name.to_s.downcase,
        caqh_id,
        caqh_id
      ).first

      return provider if provider.present?
    end

    # 4. Same name + DOB
    if birth_date.present?
      provider = Provider.where(
        "LOWER(first_name) = ? AND LOWER(last_name) = ? AND birth_date = ?",
        first_name.to_s.downcase,
        last_name.to_s.downcase,
        birth_date
      ).first

      return provider if provider.present?
    end

    # 5. Same full name fallback
    Provider.where(
      "LOWER(first_name) = ? AND LOWER(last_name) = ?",
      first_name.to_s.downcase,
      last_name.to_s.downcase
    ).first
  end

  # ============================================================
  # Enrollment Data tab
  # ============================================================

  def import_enrollment_data(sheet)
    header_row = detect_header_row(
      sheet,
      ["provider_name", "enrollment_payor", "enrollment_type", "application_status"]
    )

    headers = normalized_headers(sheet, header_row)

    Rails.logger.info "Enrollment import sheet: Enrollment Data"
    Rails.logger.info "Enrollment import header row: #{header_row}"
    Rails.logger.info "Enrollment import headers: #{headers.inspect}"

    ((header_row + 1)..sheet.last_row).each do |row_number|
      row = row_hash(sheet, headers, row_number)
      next if blank_row?(row)

      provider = find_provider_for_enrollment(row)
      raise "Provider not found for enrollment row: #{pick(row, 'provider_name')}" unless provider

      create_enrollment_provider!(provider, row)
    rescue => e
      Rails.logger.error "ENROLLMENT ROW #{row_number} FAILED"
      Rails.logger.error e.message

      @errors << {
        sheet: "Enrollment Data",
        row: row_number,
        error: e.message
      }
    end
  end

  def find_provider_for_enrollment(row)
    provider_name = pick(row, "provider_name")
    return nil if provider_name.blank?

    name = parse_full_name(provider_name)

    Provider.where(
      "LOWER(first_name) = ? AND LOWER(last_name) = ?",
      name[:first_name].to_s.downcase,
      name[:last_name].to_s.downcase
    ).first
  end

  def create_enrollment_provider!(provider, row)
    payer_name = pick(row, "enrollment_payor", "payor", "payer")
    enrollment_type = pick(row, "enrollment_type")
    status = pick(row, "application_status").presence || "pending"
    provider_external_id = pick(row, "provider_id")

    contact_names = enrollment_contact_names(row)

    EnrollmentPayer.find_or_create_by!(name: payer_name) if payer_name.present?

    enrollment = EnrollmentProvider.find_or_initialize_by(
      provider_id: provider.id,
      enrollment_payer: payer_name,
      enrollment_type: enrollment_type,
      application_id: provider_external_id
    )

    enrollment.assign_attributes(
      # Enrollment Data tab values
      name: pick(row, "provider_name"),
      first_name: contact_names[:first_name],
      middle_name: contact_names[:middle_name],
      last_name: contact_names[:last_name],
      suffix: contact_names[:suffix],

      telephone_number: pick(row, "contact_person_phone_name_from_client",
                             "phone_number_to_contact_with_insurance"),

      email_address: pick(row, "contact_person_email_name_from_client",
                          "email_address_to_contact_with_insurance"),

      enrollment_payer: payer_name,
      enrollment_type: enrollment_type,
      status: status,
      application_id: provider_external_id,
      not_submitted_note: pick(row, "notes"),

      start_date: datetime(pick(row, "start_date")),
      due_date: datetime(pick(row, "due_date")),
      revalidation_date: datetime(pick(row, "revalidation_date")),
      approved_date: datetime(pick(row, "approved_date")),

      provider_id: provider.id,
      user_id: @admin_id
    )

    enrollment.save!

    detail = EnrollmentProvidersDetail.find_or_initialize_by(
      enrollment_provider_id: enrollment.id,
      enrollment_payer: payer_name,
      enrollment_type: enrollment_type
    )

    detail.assign_attributes(
      start_date: date(pick(row, "start_date")),
      due_date: date(pick(row, "due_date")),
      enrollment_payer: payer_name,
      enrollment_type: enrollment_type,
      enrollment_status: status,

      provider_id: provider_external_id,
      payer_state: pick(row, "state"),
      payor_email: pick(row, "email_address_to_contact_with_insurance",
                        "contact_person_email_name_from_client"),
      payor_phone: pick(row, "phone_number_to_contact_with_insurance",
                        "contact_person_phone_name_from_client"),
      comment: pick(row, "notes"),

      ptan_number: pick(row, "ptan_number"),
      approved_date: date(pick(row, "approved_date")),
      revalidation_date: date(pick(row, "revalidation_date")),
      revalidation_due_date: date(pick(row, "revalidation_due_date")),
      provider_ptan: pick(row, "provider_ptan"),
      group_ptan: pick(row, "group_ptan"),
      line_of_business: pick(row, "line_of_business"),
      revalidation_status: pick(row, "revalidation_status"),
      cpt_code: pick(row, "cpt_code"),
      descriptor: pick(row, "descriptor"),
      group_id: pick(row, "group_id"),
      tax_id: pick(row, "tax_id"),
      location: pick(row, "location"),
      enrollment_effective_date: date(pick(row, "enrollment_effective_date")),
      association_start_date: date(pick(row, "association_start_date")),
      business_end_date: date(pick(row, "business_end_date")),
      association_end_date: date(pick(row, "association_end_date")),
      processing_date: date(pick(row, "processing_date")),
      terminated_date: date(pick(row, "terminated_date")),
      denied_date: date(pick(row, "denied_date"))
    )

    detail.save!

    enrollment
  end

  def enrollment_contact_names(row)
    # Your Enrollment Data tab has repeated normalized headers:
    # contact_person_name_from_client
    # contact_person_name_from_client_2
    # contact_person_name_from_client_3
    #
    # But Ruby Hash cannot keep duplicate keys unless we make headers unique.
    # So this supports both unique and non-unique versions.

    full_name =
      pick(row,
           "contact_person_name_from_client",
           "contact_person_name_from_client_1",
           "contact_person_name_from_client_2",
           "contact_person_name_from_client_3")

    parsed = parse_full_name(full_name)

    {
      first_name: parsed[:first_name],
      middle_name: parsed[:middle_name],
      last_name: parsed[:last_name],
      suffix: nil
    }
  end

  # ============================================================
  # Associated provider tables
  # ============================================================

  def create_provider_license!(provider, row)
    license_number = pick(row, "state_license_number", "license_number")
    return if license_number.blank?

    provider.licenses.find_or_initialize_by(license_number: license_number).tap do |record|
      record.assign_attributes(
        license_effective_date: date(pick(row, "state_license_effective_date", "state_license_renewal_current_effective_date")),
        license_expiration_date: date(pick(row, "state_license_expiration_date", "license_expiration_date")),
        state_id: state_id(pick(row, "state_registered", "license_state", "state")),
        license_type: pick(row, "license_type")
      )
      record.save!
    end
  end

  def create_np_license!(provider, row)
    license_number = pick(row, "np_license_number")
    return if license_number.blank?

    provider.np_licenses.find_or_initialize_by(np_license_number: license_number).tap do |record|
      record.assign_attributes(
        np_license_effective_date: date(pick(row, "np_license_effective_date")),
        np_license_expiration_date: date(pick(row, "np_license_expiration_date")),
        np_license_renewal_effective_date: date(pick(row, "np_license_renewal_effective_date")),
        state_id: state_id(pick(row, "np_license_state", "state"))
      )
      record.save!
    end
  end

  def create_rn_license!(provider, row)
    license_number = pick(row, "rn_license_number")
    return if license_number.blank?

    provider.rn_licenses.find_or_initialize_by(rn_license_number: license_number).tap do |record|
      record.assign_attributes(
        rn_license_effective_date: date(pick(row, "rn_license_effective_date", "rn_license_renewal_current_effective_date")),
        rn_license_expiration_date: date(pick(row, "rn_license_expiration_date")),
        rn_license_renewal_effective_date: date(pick(row, "rn_license_renewal_effective_date")),
        state_id: state_id(pick(row, "rn_license_state", "state"))
      )
      record.save!
    end
  end

  def create_pa_license!(provider, row)
    license_number = pick(row, "pa_license_number")
    return if license_number.blank?

    provider.pa_licenses.find_or_initialize_by(pa_license_number: license_number).tap do |record|
      record.assign_attributes(
        pa_license_effective_date: date(pick(row, "pa_license_effective_date")),
        pa_license_expiration_date: date(pick(row, "pa_license_expiration_date")),
        pa_license_renewal_effective_date: date(pick(row, "pa_license_renewal_effective_date")),
        state_id: state_id(pick(row, "pa_license_state", "state"))
      )
      record.save!
    end
  end

  def create_dea_license!(provider, row)
    dea_number = pick(row, "dea_registration_number", "dea_number", "dea_license_number")
    return if dea_number.blank?

    provider.dea_licenses.find_or_initialize_by(dea_license_number: dea_number).tap do |record|
      record.assign_attributes(
        state_id: state_id(pick(row, "dea_registration_state", "dea_license_state", "state")),
        dea_license_effective_date: date(pick(row, "dea_registration_effective_date", "dea_license_effective_date")),
        dea_license_expiration_date: date(pick(row, "dea_registration_expiration_date", "dea_license_expiration_date")),
        dea_license_renewal_effective_date: pick(row, "dea_license_renewal_effective_date")
      )
      record.save!
    end
  end

  
  def create_cds_license!(provider, row)
    cds_number = pick(row, "cds_registration_number", "cds_license_number", "cds_number")
    return if cds_number.blank?

    provider.cds_licenses.find_or_initialize_by(
      cds_license_number: cds_number
    ).tap do |record|

      record.assign_attributes(
        state_id: state_id(
          pick(row, "cds_registration_state", "cds_license_state", "state")
        ),

        cds_license_issue_date: date(
          pick(row, "cds_registration_original_license_issue_date")
        ),

        cds_license_expiration_date: date(
          pick(row, "cds_registration_expiration_date")
        ),

        cds_renewal_effective_date: date(
          pick(row, "cds_registration_renewal_date")
        )
      )

      record.save!
    end
  end

  def create_board_certification!(provider, row)
    board_name = pick(row, "board_name", "bc_board_name")
    certificate_number = pick(row, "certification_number", "board_certificate_number", "bc_certification_number")
    return if board_name.blank? && certificate_number.blank?

    provider.board_certifications.find_or_initialize_by(
      bc_board_name: board_name,
      bc_certification_number: certificate_number
    ).tap do |record|
      record.assign_attributes(
        bc_board_certification: pick(row, "board_certification", "bc_board_certification"),
        bc_specialty_type: pick(row, "specialty_type", "board_specialty_type", "bc_specialty_type"),
        bc_effective_date: datetime(pick(row, "board_effective_date", "effective_date", "bc_effective_date")),
        bc_expiration_date: datetime(pick(row, "board_expiration_date", "expiration_date", "bc_expiration_date")),
        bc_recertification_date: datetime(pick(row, "re_certification_date", "board_recertification_date", "bc_recertification_date"))
      )
      record.save!
    end
  end

  def create_ins_policy!(provider, row)
    policy_number = pick(row, "policy_number", "ins_policy_number")
    return if policy_number.blank?

    provider.ins_policies.find_or_initialize_by(ins_policy_number: policy_number).tap do |record|
      record.assign_attributes(
        effective_date: datetime(pick(row, "liability_effective_date", "effective_date", "ins_policy_effective_date")),
        expiration_date: datetime(pick(row, "liability_expiration_date", "expiration_date", "ins_policy_expiration_date"))
      )
      record.save!
    end
  end

  def create_service_location!(provider, row)
    location_name = pick(row, "practice_location_name", "facility_name", "primary_service_location_apps")
    zip = pick(row, "primary_service_zip_code", "service_location_zip_code", "zip_code", "zipcode")

    return if location_name.blank? && zip.blank?

    location = provider.service_locations.find_or_initialize_by(
      primary_service_location_apps: location_name,
      primary_service_zip_code: zip
    )

    location.assign_attributes(
      primary_service_office_email: pick(row, "primary_service_office_email", "email_address", "email"),
      primary_service_fax: pick(row, "primary_service_fax", "fax_number"),
      primary_service_location_other_phone: pick(row, "primary_service_location_other_phone", "phone_number", "telephone_number"),
      primary_service_telehealth_only_state: pick(row, "service_location_state", "state")
    )

    location.save!
  end

  def create_medicaid!(provider, row)
    medicaid_number = pick(row, "medicaid_provider_number", "medicaid_number", "medicaid")
    return if medicaid_number.blank?

    provider.medicaids.find_or_initialize_by(medicaid_number: medicaid_number).tap do |record|
      record.assign_attributes(
        effective_date: datetime(pick(row, "medicaid_effective_date", "effective_date")),
        reval_date: datetime(pick(row, "medicaid_revalidation_date", "reval_date")),
        state: pick(row, "medicaid_state", "state"),
        notes: pick(row, "medicaid_notes", "notes")
      )
      record.save!
    end
  end

  def create_medicare!(provider, row)
    medicare_number = pick(row, "medicare_provider_number", "medicare_number", "medicare")
    ptan = pick(row, "ptan_number", "medicare_ptan")
    return if medicare_number.blank? && ptan.blank?

    provider.medicares.find_or_initialize_by(
      medicare_number: medicare_number,
      ptan_number: ptan
    ).tap do |record|
      record.assign_attributes(
        effective_date: datetime(pick(row, "medicare_effective_date", "effective_date")),
        reval_date: datetime(pick(row, "medicare_revalidation_date", "reval_date")),
        state: pick(row, "medicare_state", "state"),
        notes: pick(row, "medicare_notes", "notes")
      )
      record.save!
    end
  end

  # ============================================================
  # Helpers
  # ============================================================

  def file_path
    if @file.respond_to?(:tempfile)
      @file.tempfile.path
    elsif @file.respond_to?(:path)
      @file.path
    else
      @file.to_s
    end
  end

  def safe_sheet(xlsx, sheet_name)
    xlsx.sheet(sheet_name)
  rescue
    nil
  end

  def detect_header_row(sheet, expected_headers)
    max_row = [sheet.last_row, 10].min

    (1..max_row).each do |row_number|
      headers = sheet.row(row_number).map { |header| normalize(header) }
      return row_number if (headers & expected_headers).any?
      Rails.logger.info sheet.row(row_number).inspect
      Rails.logger.info headers.inspect
    end

    raise "Header row not found for sheet. Expected one of: #{expected_headers.join(', ')}"
  end

  def normalized_headers(sheet, header_row)
    seen = Hash.new(0)

    sheet.row(header_row).map do |header|
      key = normalize(header)

      if key.blank?
        ""
      else
        seen[key] += 1
        seen[key] == 1 ? key : "#{key}_#{seen[key]}"
      end
    end
  end

  def row_hash(sheet, headers, row_number)
    values = sheet.row(row_number)
    Hash[headers.zip(values)]
  end

  def blank_row?(row)
    row.values.all?(&:blank?)
  end

  def pick(row, *keys)
    keys.each do |key|
      value = row[normalize(key)]
      return clean_cell(value) if value.present?
    end

    nil
  end

  def clean_cell(value)
    value.is_a?(String) ? value.strip : value
  end

  def normalize(value)
    value.to_s
         .strip
         .downcase
         .gsub("*", "")
         .gsub(/\(.+?\)/, "")
         .gsub(/\//, "_")
         .gsub(/&/, "and")
         .gsub(/[^a-z0-9]+/, "_")
         .gsub(/_+/, "_")
         .gsub(/^_/, "")
         .gsub(/_$/, "")
  end

  def date(value)
    return nil if value.blank?
    return value.to_date if value.respond_to?(:to_date)

    Date.parse(value.to_s)
  rescue
    nil
  end

  def datetime(value)
    return nil if value.blank?
    return value.to_datetime if value.respond_to?(:to_datetime)

    DateTime.parse(value.to_s)
  rescue
    nil
  end

  def state_id(value)
    return nil if value.blank?

    State.find_by(
      "name ILIKE ? OR alpha_code ILIKE ?",
      value.to_s.strip,
      value.to_s.strip
    )&.id
  end

  def state_alpha_or_value(value)
    return nil if value.blank?

    State.find_by(
      "name ILIKE ? OR alpha_code ILIKE ?",
      value.to_s.strip,
      value.to_s.strip
    )&.alpha_code || value
  end

  def default_enrollment_group
    return EnrollmentGroup.find(@enrollment_group_id) if @enrollment_group_id.present?

    EnrollmentGroup.first || EnrollmentGroup.create!(
      group_name: "Dummy Enrollment Group",
      group_code: "DUMMY"
    )
  end

  def parse_full_name(full_name)
    parts = full_name.to_s.strip.split(/\s+/)

    case parts.length
    when 0
      { first_name: nil, middle_name: nil, last_name: nil }
    when 1
      { first_name: parts[0], middle_name: nil, last_name: nil }
    when 2
      { first_name: parts[0], middle_name: nil, last_name: parts[1] }
    else
      { first_name: parts[0], middle_name: parts[1...-1].join(" "), last_name: parts[-1] }
    end
  end
end
