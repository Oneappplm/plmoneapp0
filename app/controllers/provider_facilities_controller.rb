class ProviderFacilitiesController < ApplicationController
  before_action :set_provider,
                only: %i[
                  edit
                  update
                  autosave
                  delete_facility_document
                ]

  before_action :set_provider_attest,
                only: %i[
                  edit
                  update
                  autosave
                  delete_facility_document
                ]

  before_action :set_step, only: %i[edit update autosave]
  before_action :load_application_submission_state,
              only: %i[edit update autosave]

  STEPS = %w[
    provider_type
    corporate_information
    primary_office_contact
    mailing_address
    licensure_certification
    accreditation
    insurance
    staffing
    facility_profile
    attestation
    upload_documents
    confirmation
  ].freeze

  PRE_APPLICATION_QUESTIONS = [
    "Do you have a facility located in Wayne County?",
    "Is program currently active and providing services?",
    "Do you currently have employees that are trained to deliver services you are wanting to provide?",
    "Has your organization been disbarred or sanctioned through Medicaid and/or Medicare?"
  ].freeze

  FACILITY_PROFILE_1_QUESTIONS = [
    "Does each service address comply with ADA (Americans with Disabilities Act) regulations?",
    "Is each service address accessible by public transportation?",
    "Does your facility complete the Supports Intensity Scale (SIS) on individuals as appropriate?",
    "Does your facility complete an Individual Plan of Services?",
    "Do you accept Healthy Michigan at each service address?",
    "Do you accept Medicaid at each service address?",
    "Do you accept Medicare at each service address?",
    "Does your facility complete the Level of Care Utilization System (LOCUS) Tool?"
  ].freeze

  FACILITY_PROFILE_2_QUESTIONS = {
    training_experience: "Facility Profile 2 - Training and experience",
    genders_served: "Facility Profile 2 - Genders served",
    michiide_snp: "Facility Profile 2 - MICHIIDE SNP",
    age_groups: "Facility Profile 2 - Age groups",
    populations_treated: "Facility Profile 2 - Populations treated",
    treatment_languages: "Facility Profile 2 - Treatment languages",
    total_beds: "Facility Profile 2 - Total number of beds",
    maximum_capacity: "Facility Profile 2 - Maximum program capacity"
  }.freeze

  FACILITY_PROVIDER_TYPE_QUESTION =
  "Facility Profile - Provider Type".freeze

  FACILITY_SERVICE_TYPE_QUESTIONS = {
    sud_treatment_provider: "Facility Service Type - SUD Treatment Provider",
    sud_prevention_provider: "Facility Service Type - SUD Prevention Provider",
    selected_services: "Facility Service Type - Selected Services"
  }.freeze

  ATTESTATION_QUESTIONS = [
    "Has the organization's state license/certificate ever been revoked, suspended or limited?",
    "Is there action pending to suspend, revoke, or limit the organization's license/certification?",
    "Has the organization ever had its JCAHO, CARF, COA, AOA, NCQA or any other accreditation revoked, suspended or limited?",
    "Is there action pending to revoke, suspend, or limit the organization's current accreditation?",
    "Has the organization ever had sanctions imposed by Medicaid?",
    "Has the organization ever had sanctions imposed by Medicare?",
    "Has the organization's commercial general or professional liability insurance ever been denied, cancelled, non-renewed, or initially refused upon application?",
    "Has the organization ever been a defendant in any lawsuit related to mental health or substance abuse treatment where there has been an award or payment of $50,000 or more?",
    "Has the organization had any malpractice claims related to mental health or substance abuse treatment?",
    "Does the provider entity, including staff, have any financial relationship, shared governance, or shared administrative capacity with another provider entity in Wayne County?"
  ].freeze

  REQUIRED_FACILITY_DOCUMENTS = [
    "W-9 Form",
    "State License or Certification",
    "Accreditation Certificate",
    "Professional Liability Insurance",
    "General Liability Insurance"
  ].freeze

  OPTIONAL_FACILITY_DOCUMENTS = [
    "CLIA Certificate",
    "DEA Certificate",
    "Board Certification",
    "Organizational Chart",
    "Additional Supporting Document"
  ].freeze

  FACILITY_DOCUMENTS = [
    {
      key: "champs_document",
      title: "CHAMPS document",
      required: false
    },
    {
      key: "state_local_licenses",
      title: "Copy of all State and/or local licenses required to operate",
      required: false
    },
    {
      key: "commercial_liability",
      title: "Copy of Commercial General Liability Insurance certificate",
      required: true
    },
    {
      key: "professional_liability",
      title: "Copy of Professional Liability Insurance certificate covering all agency employees",
      required: true
    },
    {
      key: "workers_compensation",
      title: "Copy of Workers Compensation Insurance",
      required: true
    },
    {
      key: "accreditation_certificate",
      title: "Copy of Accreditation certificate or letter",
      required: false
    },
    {
      key: "w9_form",
      title: "W9 Form",
      required: true
    },
    {
      key: "fire_safety_certificate",
      title: "Fire/Safety Inspection Certificate for each facility you are requesting to be impaneled",
      required: false
    },
    {
      key: "sam_registration",
      title: "SAM.gov registration",
      required: true
    },
    {
      key: "board_of_directors",
      title: "Board of Directors/or Organization Owners",
      required: false
    },
    {
      key: "other",
      title: "Other",
      required: false
    },
    {
      key: "read_and_attest",
      title: "Please download this form, read, and attest",
      required: true
    }
  ].freeze

  helper_method :previous_step, :main_step

  def edit
    prepare_step_data
  end

  def update
    if program_staff_request?
      handle_program_staff_request
      return
    end

    if practice_location_delete_request?
      delete_practice_location

      render json: {
        success: true
      }

      return
    end

    if application_submission_request?
      saved = save_step_data

      unless saved
        @step = params[:step].presence || @step

        prepare_step_data
        load_application_submission_state

        flash.now[:alert] =
          "Please correct the errors below."

        render :edit, status: :unprocessable_entity
        return
      end

      submit_application

      redirect_to edit_provider_facility_path(
        @provider,
        step: "confirmation",
        submitted: "1"
      )

      return
    end

    saved = save_step_data

    unless saved
      @step = params[:step].presence || @step

      prepare_step_data
      load_application_submission_state

      flash.now[:alert] =
        "Please correct the errors below."

      render :edit, status: :unprocessable_entity
      return
    end

    if params[:commit] == "Upload Documents"
      redirect_to edit_provider_facility_path(
        @provider,
        step: "upload_documents"
      ), notice: "Documents uploaded successfully."

      return
    end

    if params[:save_on_tab_change] == "1"
      redirect_to edit_provider_facility_path(
        @provider,
        step: "facility_profile",
        facility_tab: params[:redirect_facility_tab],
        practice_location_id: resolve_practice_location_id
      )

      return
    end

    if params[:commit] == "Save & Next"
      redirect_to edit_provider_facility_path(
        @provider,
        step: next_step
      )
    else
      redirect_to edit_provider_facility_path(
        @provider,
        step: @step,
        facility_tab: params[:facility_tab],
        practice_location_id: resolve_practice_location_id
      ), notice: "Saved successfully."
    end

  rescue ActiveRecord::RecordInvalid => error
    if request.xhr? || request.format.json?
      render json: {
        success: false,
        errors: error.record.errors.full_messages
      }, status: :unprocessable_entity
    else
      @step = params[:step].presence || @step

      prepare_step_data
      load_application_submission_state

      flash.now[:alert] =
        error.record.errors.full_messages.to_sentence

      render :edit, status: :unprocessable_entity
    end
  end

  def autosave
    save_step_data
    head :ok
  end

  def delete_practice_location
    @practice_information =
      @provider_attest.practice_informations.first!

    location =
      @practice_information.practice_locations.find(params[:practice_location_id])

    location.destroy!
  end

  def delete_facility_document
    document =
      ProviderPersonalUploadedDoc.find_by!(
        id: params[:document_id],
        provider_attest_id: @provider_attest.id,
        provider_personal_information_id: @provider.id,
        sub_section: "facilities"
      )

    document_id = document.id
    record_item = document.record_item

    document.destroy!

    remaining_count =
      ProviderPersonalUploadedDoc.where(
        provider_attest_id: @provider_attest.id,
        provider_personal_information_id: @provider.id,
        sub_section: "facilities",
        record_item: record_item
      ).count

    render json: {
      success: true,
      message: "Document deleted successfully.",
      document_id: document_id,
      record_item: record_item,
      remaining_count: remaining_count
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: "The uploaded document could not be found."
    }, status: :not_found
  rescue ActiveRecord::RecordNotDestroyed => error
    render json: {
      success: false,
      message: error.record.errors.full_messages.to_sentence
    }, status: :unprocessable_entity
  rescue StandardError => error
    Rails.logger.error(
      "[Facility Document Delete] #{error.class}: #{error.message}"
    )

    render json: {
      success: false,
      message: "The document could not be deleted. Please try again."
    }, status: :internal_server_error
  end

  private

  def load_application_submission_state
    @latest_application_tracking =
      @provider
        .provider_personal_information_app_trackings
        .where.not(application_submitted_date: nil)
        .order(application_submitted_date: :desc, created_at: :desc)
        .first

    @last_submitted_date =
      @latest_application_tracking&.application_submitted_date ||
      @provider.attest_date

    @application_previously_submitted =
      @last_submitted_date.present?

    @show_submission_success =
      @step == "confirmation" &&
      params[:submitted] == "1"
  end

  # def confirmation_submission_request?
  #   @step == "confirmation" &&
  #     params[:confirmation_action] == "submit_application"
  # end

  def application_submission_request?
    params[:application_action] == "submit_application"
  end

  def resolve_practice_location_id
    @practice_location&.id || params[:practice_location_id]
  end

  def set_provider
    @provider = ProviderPersonalInformation.find(params[:id])
  end

  def set_provider_attest
    @provider_attest = @provider.provider_attest
  end

  def set_step
    @step = params[:step].presence || STEPS.first
    redirect_to edit_provider_facility_path(@provider, step: STEPS.first) unless STEPS.include?(@step)
  end

  def practice_location_delete_request?
    @step == "facility_profile" &&
      params[:facility_action] == "delete"
  end

  def prepare_step_data
    case @step
    when "provider_type"
      build_pre_application_disclosures
    when "corporate_information"
      build_corporate_information
    when "primary_office_contact"
      build_primary_office_contact
    when "mailing_address"
      build_mailing_address
    when "licensure_certification"
      build_provider_licensures
    when "accreditation"
      build_accreditation
    when "insurance"
      build_insurance
    when "staffing"
      build_staffing
    when "facility_profile"
      build_facility_profile

      case @facility_tab
      when "program_staff"
        build_facility_program_staff
      when "facility_profile_1"
        build_facility_profile_1
      when "facility_profile_2"
        build_facility_profile_2
      when "provider_type_tab"
        build_facility_provider_type
      when "service_type"
        build_facility_service_type    
      end
    when "attestation"
      build_attestation
    when "upload_documents"
      build_upload_documents
    when "confirmation"
      build_confirmation  
    end
  end

  def save_step_data
    case @step
    when "provider_type"
      save_pre_application_disclosures
    when "corporate_information"
      save_corporate_information
    when "primary_office_contact"
      save_primary_office_contact
    when "mailing_address"
      save_mailing_address
    when "licensure_certification"
      save_provider_licensures    
    when "accreditation"
      save_accreditation
    when "insurance"
      save_insurance
    when "staffing"
      save_staffing
    when "facility_profile"
      case params[:facility_tab]
      when "practice_location"
        save_facility_profile
      when "facility_profile_1"
        save_facility_profile_1
      when "facility_profile_2"
        save_facility_profile_2
      when "provider_type_tab"
        save_facility_provider_type
      when "service_type"
        save_facility_service_type    
      when "program_staff"
        # Saved separately through AJAX Insert/Update/Delete
      end
    when "attestation"
      save_attestation  
    when "upload_documents"
      save_uploaded_documents
    when "confirmation"
      true
    else
      true  
    end
  end

  def build_pre_application_disclosures
    PRE_APPLICATION_QUESTIONS.each do |question|
      @provider_attest.provider_disclosures.find_or_initialize_by(
        disclosure_question_disclosure_summary: question
      )
    end
  end

  def build_confirmation;  end

  def save_pre_application_disclosures
    return if params[:provider_disclosures].blank?

    params[:provider_disclosures].each do |_index, item|
      disclosure = @provider_attest.provider_disclosures.find_or_initialize_by(
        disclosure_question_disclosure_summary: item[:question]
      )

      disclosure.update!(
        provider_attest_id: @provider_attest.id,
        caqh_provider_attest_id: @provider.caqh_provider_attest_id,
        disclosure_question_disclosure_summary: item[:question],
        disclosure_answer_flag: item[:answer] == "yes",
        disclosure_explanation: item[:explanation]
      )
    end
  end

  def build_corporate_information
    @practice_information = @provider_attest.practice_informations.first_or_initialize
  end

  def save_corporate_information
    build_corporate_information

    data = params.require(:practice_information).permit(
      :legal_business_name,
      :dba_name,
      :npi,
      :no_npi_reason,
      :federal_tax_id,
      :incorporated_state,
      :counties_served,
      :submit_claims_electronically,
      :ceo_first_name,
      :ceo_middle_name,
      :ceo_last_name,
      :type_and_ownership
    )

    @practice_information.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_name: data[:legal_business_name],
      group_name: data[:dba_name],
      npi: data[:npi],
      any_comments: data[:no_npi_reason],
      federal_tax_id: data[:federal_tax_id],
      state: data[:incorporated_state],
      county: data[:counties_served],
      electronic_billing_flag: data[:submit_claims_electronically] == "true",
      office_manager: [
        data[:ceo_first_name],
        data[:ceo_middle_name],
        data[:ceo_last_name]
      ].compact.join(" ").squish,
      ownership_description: data[:type_and_ownership]
    )
  end

  def build_provider_licensures
    @provider_licensures = @provider_attest.provider_licensures

    @provider_licensures.build if @provider_licensures.blank?
  end

  def save_provider_licensures
    return if params[:provider_licensures].blank?

    params[:provider_licensures].each do |_index, data|
      licensure =
        if data[:id].present?
          @provider_attest.provider_licensures.find(data[:id])
        else
          @provider_attest.provider_licensures.new
        end

      if data[:_destroy] == "1"
        licensure.destroy if licensure.persisted?
        next
      end

      licensure.update!(
        provider_attest_id: @provider_attest.id,
        caqh_provider_attest_id: @provider.caqh_provider_attest_id,

        state_id: data[:state_id],
        license_type: data[:license_type],
        license_number: data[:license_number],
        license_issue_date: data[:license_issue_date],
        license_expiration_date: data[:license_expiration_date],

        currently_practice_under_this: data[:currently_practice_under_this] == "1",
        is_primary_license: data[:is_primary_license] == "1",
        level_require_supervision: data[:level_require_supervision] == "1",

        license_person_type: data[:license_person_type],
        license_comment: data[:license_comment]
      )
    end
  end

  def build_primary_office_contact
    @practice_information = @provider_attest.practice_informations.first_or_initialize
  end

  def save_primary_office_contact
    build_primary_office_contact

    data = params.require(:practice_information).permit(
      :address_line_1,
      :address_line_2,
      :city,
      :county,
      :state,
      :zip,
      :phone,
      :fax,
      :email,
      :website_address,
      :contact_first_name,
      :contact_middle_name,
      :contact_last_name,
      :contact_phone,
      :contact_fax,
      :contact_email
    )

    @practice_information.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      address: data[:address_line_1],
      address2: data[:address_line_2],
      city: data[:city],
      county: data[:county],
      state: data[:state],
      zip: data[:zip],
      phone_number: data[:phone],
      fax_number: data[:fax],
      email_address: data[:email],
      practice_description: data[:website_address],
      office_manager: [
        data[:contact_first_name],
        data[:contact_middle_name],
        data[:contact_last_name]
      ].compact.join(" ").squish,
      manager_phone_number: data[:contact_phone],
      manager_fax_number: data[:contact_fax]
    )
  end

  def build_mailing_address
    @practice_information = @provider_attest.practice_informations.first_or_initialize
  end

  def save_mailing_address
    build_mailing_address

    data = params.require(:practice_information).permit(
      :mailing_name,
      :mailing_address,
      :mailing_address2,
      :mailing_city,
      :mailing_state,
      :mailing_zip,
      :mailing_phone,
      :mailing_fax,
      :mailing_email
    )

    @practice_information.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,

      practice_name: data[:mailing_name],
      address: data[:mailing_address],
      address2: data[:mailing_address2],
      city: data[:mailing_city],
      state: data[:mailing_state],
      zip: data[:mailing_zip],
      phone_number: data[:mailing_phone],
      fax_number: data[:mailing_fax],
      email_address: data[:mailing_email]
    )
  end

  def build_accreditation
    @practice_information = @provider_attest.practice_informations.first_or_initialize

    @practice_certification =
      @provider_attest.practice_certifications
                      .where(practice_information_id: @practice_information.id)
                      .first_or_initialize
  end

  def save_accreditation
    build_accreditation

    data = params.require(:practice_certification).permit(
      :other_accreditation_name,
      :medicaid_certified,
      :medicare_certified,
      :sam_registered,
      accreditation_names: []
    )

    @practice_certification.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      certification_description: data[:accreditation_names]&.reject(&:blank?)&.join(", "),
      other_certification_explanation: data[:other_accreditation_name],
      certification_flag: data[:medicaid_certified] == "yes",
      staff_certified_flag: data[:medicare_certified] == "yes",
      provider_certified_flag: data[:sam_registered] == "yes"
    )
  end

  def build_insurance
    @insurance_coverage = @provider_attest.provider_insurance_coverages.first_or_initialize
  end

  def save_insurance
    build_insurance

    data = params.require(:provider_insurance_coverage).permit(
      :commercial_general_liability,
      :professional_liability,
      :workers_compensation
    )

    @insurance_coverage.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      insurance_type_insurance_type_description: data[:commercial_general_liability],
      type_of_policy: data[:professional_liability],
      insurance_coverage_type_insurance_coverage_type_description: data[:workers_compensation]
    )
  end

  def build_staffing
    @practice_information = @provider_attest.practice_informations.first_or_create!

    @staffing_question =
      @provider_attest.practice_other_questions
                      .where(other_question_other_question_summary: "Does this organization validate employee credentials?")
                      .first_or_initialize
  end

  def save_staffing
    build_staffing

    data = params.require(:practice_other_question).permit(
      :provider_practice_answer_flag,
      :provider_practice_answer_text,
      :provider_practice_answer_extra,
      :no_explanation
    )

    answer = data[:provider_practice_answer_flag]

    answer_text =
      if answer == "yes"
        if data[:provider_practice_answer_text].to_s.include?("outsourced")
          "Credentialing procedures are outsourced/delegated to: #{data[:provider_practice_answer_extra]}"
        elsif data[:provider_practice_answer_text] == "Other"
          "Other: #{data[:provider_practice_answer_extra]}"
        else
          data[:provider_practice_answer_text]
        end
      elsif answer == "no"
        data[:no_explanation]
      else
        nil
      end

    @staffing_question.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary: "Does this organization validate employee credentials?",
      provider_practice_answer_flag: answer == "yes" ? true : answer == "no" ? false : nil,
      provider_practice_answer_text: answer_text
    )
  end

  def build_facility_profile
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @practice_locations =
      @practice_information.practice_locations.reload.to_a

    @practice_location =
      if params[:new_practice_location] == "1"
        @practice_information.practice_locations.build
      elsif params[:practice_location_id].present?
        @practice_information.practice_locations.find_by(
          id: params[:practice_location_id]
        )
      end

    @facility_tab =
      params[:facility_tab].presence || "practice_location"
  end

  def save_facility_profile
    build_facility_profile

    data = params.require(:practice_location).permit(
      :id,
      :location,
      :address1,
      :address2,
      :city,
      :state_id,
      :zip_code,
      :phone_number,
      :fax_number,
      :email
    )

    @practice_location =
      if data[:id].present?
        @practice_information.practice_locations.find(data[:id])
      else
        @practice_information.practice_locations.new
      end

    @practice_location.update!(
      location: data[:location],
      legal_name: data[:location],
      address1: data[:address1],
      address2: data[:address2],
      city: data[:city],
      state_id: data[:state_id],
      zip_code: data[:zip_code],
      phone_number: data[:phone_number],
      fax_number: data[:fax_number],
      email: data[:email].presence || "no-email-#{Time.current.to_i}@example.com",
      group_tax_number: @practice_information.federal_tax_id.presence || @practice_information.tax_id.presence || "N/A",
      practice_information_id: @practice_information.id
    )
  end

  def program_staff_request?
    @step == "facility_profile" &&
      params[:facility_tab] == "program_staff" &&
      params[:program_staff_action].in?(%w[insert update delete])
  end

  def handle_program_staff_request
    case params[:program_staff_action]
    when "insert"
      staff = insert_program_staff

      render json: {
        success: true,
        staff: program_staff_json(staff)
      }
    when "update"
      staff = update_program_staff

      render json: {
        success: true,
        staff: program_staff_json(staff)
      }
    when "delete"
      staff_id = delete_program_staff

      render json: {
        success: true,
        staff_id: staff_id
      }
    end
  end

  def build_facility_program_staff
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @program_staffs =
      @practice_information.practice_associates.order(:id)
  end

  def program_staff_context
    @practice_information =
      @provider_attest.practice_informations.first_or_create!
  end

  def insert_program_staff
    program_staff_context

    staff = @practice_information.practice_associates.new(
      program_staff_attributes
    )

    assign_program_staff_parent_fields(staff)
    staff.save!

    staff
  end

  def update_program_staff
    program_staff_context

    staff = @practice_information.practice_associates.find(
      params.require(:staff_id)
    )

    staff.assign_attributes(program_staff_attributes)
    assign_program_staff_parent_fields(staff)
    staff.save!

    staff
  end

  def delete_program_staff
    program_staff_context

    staff = @practice_information.practice_associates.find(
      params.require(:staff_id)
    )

    staff_id = staff.id
    staff.destroy!

    staff_id
  end

  def program_staff_attributes
    {
      associate_first_name: params[:first_name].to_s.strip,
      associate_middle_initial: params[:middle_name].to_s.strip,
      associate_last_name: params[:last_name].to_s.strip,
      provider_type_provider_type_abbreviation: params[:npi].to_s.strip,
      degree_degree_abbreviation: params[:degree].to_s.strip,
      title: params[:job_title].to_s.strip,
      license_number: params[:licensure].to_s.strip,
      other_skills: params[:certification].to_s.strip
    }
  end

  def assign_program_staff_parent_fields(staff)
    staff.provider_attest_id = @provider_attest.id
    staff.caqh_provider_attest_id = @provider.caqh_provider_attest_id
    staff.practice_information_id = @practice_information.id
  end

  def program_staff_json(staff)
    {
      id: staff.id,
      associate_first_name: staff.associate_first_name,
      associate_middle_initial: staff.associate_middle_initial,
      associate_last_name: staff.associate_last_name,
      provider_type_provider_type_abbreviation:
        staff.provider_type_provider_type_abbreviation,
      title: staff.title,
      degree_degree_abbreviation: staff.degree_degree_abbreviation,
      license_number: staff.license_number,
      other_skills: staff.other_skills
    }
  end
  def build_facility_profile_1
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @facility_profile_1_questions =
      FACILITY_PROFILE_1_QUESTIONS.map do |question|
        @provider_attest.practice_other_questions.find_or_initialize_by(
          practice_information_id: @practice_information.id,
          other_question_other_question_summary: question
        )
      end
  end

  def save_facility_profile_1
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    return if params[:facility_profile_questions].blank?

    params[:facility_profile_questions].each_value do |item|
      question = item[:question].to_s

      next unless FACILITY_PROFILE_1_QUESTIONS.include?(question)

      record =
        @provider_attest.practice_other_questions.find_or_initialize_by(
          practice_information_id: @practice_information.id,
          other_question_other_question_summary: question
        )

      answer_flag =
        case item[:answer]
        when "yes"
          true
        when "no"
          false
        else
          nil
        end

      record.update!(
        provider_attest_id: @provider_attest.id,
        caqh_provider_attest_id: @provider.caqh_provider_attest_id,
        practice_information_id: @practice_information.id,
        other_question_other_question_summary: question,
        provider_practice_answer_flag: answer_flag,
        provider_practice_answer_text:
          item[:answer] == "no" ? item[:explanation].to_s.strip : nil
      )
    end
  end
  def build_facility_profile_2
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @facility_profile_2_records =
      FACILITY_PROFILE_2_QUESTIONS.transform_values do |question|
        @provider_attest.practice_other_questions.find_or_initialize_by(
          practice_information_id: @practice_information.id,
          other_question_other_question_summary: question
        )
      end
  end

  def save_facility_profile_2
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    data = params.require(:facility_profile_2).permit(
      :michiide_snp,
      :treatment_languages,
      :total_beds,
      :maximum_capacity,
      training_experience: [],
      genders_served: [],
      age_groups: [],
      populations_treated: []
    )

    save_facility_profile_2_text(
      :training_experience,
      Array(data[:training_experience]).reject(&:blank?).join(", ")
    )

    save_facility_profile_2_text(
      :genders_served,
      Array(data[:genders_served]).reject(&:blank?).join(", ")
    )

    save_facility_profile_2_boolean(
      :michiide_snp,
      data[:michiide_snp]
    )

    save_facility_profile_2_text(
      :age_groups,
      Array(data[:age_groups]).reject(&:blank?).join(", ")
    )

    save_facility_profile_2_text(
      :populations_treated,
      Array(data[:populations_treated]).reject(&:blank?).join(", ")
    )

    save_facility_profile_2_text(
      :treatment_languages,
      data[:treatment_languages].to_s.strip
    )

    save_facility_profile_2_text(
      :total_beds,
      data[:total_beds].to_s.strip
    )

    save_facility_profile_2_text(
      :maximum_capacity,
      data[:maximum_capacity].to_s.strip
    )
  end

  def save_facility_profile_2_text(key, value)
    question = FACILITY_PROFILE_2_QUESTIONS.fetch(key)

    record =
      @provider_attest.practice_other_questions.find_or_initialize_by(
        practice_information_id: @practice_information.id,
        other_question_other_question_summary: question
      )

    record.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary: question,
      provider_practice_answer_text: value
    )
  end

  def save_facility_profile_2_boolean(key, value)
    question = FACILITY_PROFILE_2_QUESTIONS.fetch(key)

    record =
      @provider_attest.practice_other_questions.find_or_initialize_by(
        practice_information_id: @practice_information.id,
        other_question_other_question_summary: question
      )

    answer_flag =
      case value
      when "yes"
        true
      when "no"
        false
      else
        nil
      end

    record.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary: question,
      provider_practice_answer_flag: answer_flag
    )
  end

  def build_facility_provider_type
  @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @facility_provider_type =
      @provider_attest.practice_other_questions.find_or_initialize_by(
        practice_information_id: @practice_information.id,
        other_question_other_question_summary:
          FACILITY_PROVIDER_TYPE_QUESTION
      )
  end

  def save_facility_provider_type
    build_facility_provider_type

    data = params.require(:facility_provider_type).permit(
      :provider_type,
      :other_provider_type
    )

    selected_type = data[:provider_type].to_s

    answer_text =
      if selected_type == "Other Provider Type"
        other_value = data[:other_provider_type].to_s.strip

        if other_value.present?
          "Other Provider Type: #{other_value}"
        else
          "Other Provider Type"
        end
      else
        selected_type
      end

    @facility_provider_type.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary:
        FACILITY_PROVIDER_TYPE_QUESTION,
      provider_practice_answer_text: answer_text
    )
  end

  def build_facility_service_type
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    @facility_service_type_records =
      FACILITY_SERVICE_TYPE_QUESTIONS.transform_values do |question|
        @provider_attest.practice_other_questions.find_or_initialize_by(
          practice_information_id: @practice_information.id,
          other_question_other_question_summary: question
        )
      end
  end

  def save_facility_service_type
    @practice_information =
      @provider_attest.practice_informations.first_or_create!

    data = params.require(:facility_service_type).permit(
      :sud_treatment_provider,
      :sud_prevention_provider,
      selected_services: []
    )

    save_facility_service_boolean(
      :sud_treatment_provider,
      data[:sud_treatment_provider]
    )

    save_facility_service_boolean(
      :sud_prevention_provider,
      data[:sud_prevention_provider]
    )

    selected_services =
      Array(data[:selected_services])
        .reject(&:blank?)
        .select { |service| PracticeLocation::LOCATION_SERVICES.include?(service) }

    save_facility_service_text(
      :selected_services,
      selected_services.join(", ")
    )
  end

  def save_facility_service_boolean(key, value)
    question = FACILITY_SERVICE_TYPE_QUESTIONS.fetch(key)

    record =
      @provider_attest.practice_other_questions.find_or_initialize_by(
        practice_information_id: @practice_information.id,
        other_question_other_question_summary: question
      )

    answer_flag =
      case value
      when "yes"
        true
      when "no"
        false
      else
        nil
      end

    record.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary: question,
      provider_practice_answer_flag: answer_flag
    )
  end

  def save_facility_service_text(key, value)
    question = FACILITY_SERVICE_TYPE_QUESTIONS.fetch(key)

    record =
      @provider_attest.practice_other_questions.find_or_initialize_by(
        practice_information_id: @practice_information.id,
        other_question_other_question_summary: question
      )

    record.update!(
      provider_attest_id: @provider_attest.id,
      caqh_provider_attest_id: @provider.caqh_provider_attest_id,
      practice_information_id: @practice_information.id,
      other_question_other_question_summary: question,
      provider_practice_answer_text: value
    )
  end

  def build_attestation
    @attestation_questions ||= ATTESTATION_QUESTIONS

    @attestation_disclosures ||= @attestation_questions.map do |question|
      @provider_attest.provider_disclosures.find_or_initialize_by(
        disclosure_question_disclosure_summary: question
      )
    end

    @attestation_errors ||= {}
  end

  def save_attestation
    answers = params[:attestation_answers] || {}

    @attestation_errors = {}
    records_to_save = []

    ATTESTATION_QUESTIONS.each_with_index do |question, index|
      answer_data = answers[index.to_s] || {}

      answer = answer_data[:answer].to_s
      explanation = answer_data[:explanation].to_s.strip

      if answer.blank?
        @attestation_errors[index] = "Please select Yes, No, or N/A."
        next
      end

      if answer == "yes" && explanation.blank?
        @attestation_errors[index] =
          "Please provide an explanation when Yes is selected."

        next
      end

      disclosure =
        @provider_attest.provider_disclosures.find_or_initialize_by(
          disclosure_question_disclosure_summary: question
        )

      disclosure.disclosure_answer_flag =
        case answer
        when "yes"
          true
        when "no"
          false
        when "na"
          nil
        end

      disclosure.disclosure_explanation =
        answer == "yes" ? explanation : nil

      disclosure.disclosure_date = Date.current if disclosure.respond_to?(:disclosure_date=)

      records_to_save << disclosure
    end

    if @attestation_errors.present?
      @attestation_disclosures = ATTESTATION_QUESTIONS.map do |question|
        @provider_attest.provider_disclosures.find_or_initialize_by(
          disclosure_question_disclosure_summary: question
        )
      end

      return false
    end

    ProviderDisclosure.transaction do
      records_to_save.each(&:save!)
    end

    true
  end

  def build_upload_documents
    @facility_documents = FACILITY_DOCUMENTS
    @provider_personal_information = @provider

    upload_scope =
      ProviderPersonalUploadedDoc.where(
        provider_attest_id: @provider_attest.id,
        provider_personal_information_id: @provider.id,
        sub_section: "facilities"
      )

    @uploaded_documents =
      upload_scope.order(created_at: :desc)

    @uploaded_document_counts =
      upload_scope.group(:record_item).count

    @upload_document_errors ||= {}
  end

  def save_uploaded_documents
    @upload_document_errors = {}

    selected_documents =
      selected_facility_documents(params[:facility_documents])

    # Save all files that the user selected.
    upload_facility_documents(selected_documents) if selected_documents.present?

    # After saving, validate every required document against the database.
    validate_required_facility_documents

    @upload_document_errors.blank?
  end

  def selected_facility_documents(submitted_documents)
    return [] if submitted_documents.blank?

    submitted_documents.each_value.filter_map do |document_data|
      next unless document_data.respond_to?(:permit)

      permitted_data =
        document_data.permit(:record_item, :file_upload)

      uploaded_file = permitted_data[:file_upload]
      next if uploaded_file.blank?

      {
        record_item: permitted_data[:record_item].to_s.strip,
        file_upload: uploaded_file
      }
    end
  end

  def upload_facility_documents(selected_documents)
    valid_document_titles =
      FACILITY_DOCUMENTS.map { |document| document[:title] }

    selected_documents.each do |document_data|
      document_type = document_data[:record_item].to_s.strip
      uploaded_file = document_data[:file_upload]

      unless valid_document_titles.include?(document_type)
        @upload_document_errors[:base] =
          "The selected document type is invalid."

        next
      end

      file_error = facility_document_file_error(uploaded_file)

      if file_error.present?
        @upload_document_errors[document_type] = file_error
        next
      end

      document = ProviderPersonalUploadedDoc.new(
        provider_attest_id: @provider_attest.id,
        caqh_provider_attest_id: @provider.caqh_provider_attest_id,
        provider_personal_information_id: @provider.id,
        caqh_provider_id: provider_caqh_id,
        sub_section: "facilities",
        record_item: document_type,
        description: document_type,
        exclude_from_profile: false,
        file_upload: uploaded_file
      )

      assign_facility_image_classification(document)

      unless document.save
        @upload_document_errors[document_type] =
          document.errors.full_messages.to_sentence
      end
    end
  end

  def assign_facility_image_classification(document)
    return unless ProviderPersonalUploadedDoc.respond_to?(:image_classifications)

    valid_values =
      ProviderPersonalUploadedDoc.image_classifications.keys

    preferred_value =
      %w[
        provider_facility
        facility
        provider_document
        other
      ].find { |value| valid_values.include?(value) }

    document.image_classification = preferred_value if preferred_value.present?
  end

  def provider_caqh_id
    return @provider.caqh_provider_id if @provider.respond_to?(:caqh_provider_id)

    nil
  end

  def facility_document_file_error(uploaded_file)
    return "Please select a file." if uploaded_file.blank?

    allowed_extensions = %w[pdf doc docx jpg jpeg png]

    extension =
      File.extname(uploaded_file.original_filename.to_s)
          .delete_prefix(".")
          .downcase

    unless allowed_extensions.include?(extension)
      return "Allowed formats are PDF, DOC, DOCX, JPG, JPEG, and PNG."
    end

    if uploaded_file.size.to_i > 10.megabytes
      return "File size must be less than 10 MB."
    end

    nil
  end


  def validate_required_facility_documents
    required_documents =
      FACILITY_DOCUMENTS.select { |document| document[:required] }

    required_document_names =
      required_documents.map { |document| document[:title] }

    uploaded_document_names =
      ProviderPersonalUploadedDoc
        .where(
          provider_attest_id: @provider_attest.id,
          provider_personal_information_id: @provider.id,
          sub_section: "facilities",
          record_item: required_document_names
        )
        .where.not(file_upload: [nil, ""])
        .distinct
        .pluck(:record_item)

    required_documents.each do |document|
      document_name = document[:title]

      next if uploaded_document_names.include?(document_name)

      @upload_document_errors[document_name] ||=
        "This document is required."
    end
  end

  def submit_application
    submitted_at = Time.current

    ProviderPersonalInformation.transaction do
      @provider.update!(
        progress_status: "completed",
        attest_date: submitted_at.to_date
      )

      tracking =
        @provider
          .provider_personal_information_app_trackings
          .order(created_at: :desc)
          .first_or_initialize

      tracking.application_submitted_date = submitted_at

      if tracking.application_type.blank?
        tracking.application_type =
          @provider.application_type
      end

      tracking.file_status = "submitted" if tracking.file_status.blank?

      tracking.save!
    end

    true
  end

  def next_step
    current_index = STEPS.index(@step)
    STEPS[current_index + 1] || @step
  end

  def previous_step
    current_index = STEPS.index(@step)
    current_index&.positive? ? STEPS[current_index - 1] : STEPS.first
  end

  def main_step
    case @step
    when "provider_type"
      "provider_type"
    when "upload_documents"
      "upload_documents"
    when "confirmation"
      "confirmation"
    else
      "profile_data"
    end
  end
end
