class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end

  def show
    if params[:page_tab]
      get_data

      render params[:page_tab]
    else
      render 'overview'
    end
  end

  protected
  def set_provider_personal_informations
    @provider_personal_information = ProviderPersonalInformation.find_by(provider_attest_id: params[:id])
    # @practice_informations = @provider_personal_information.provider_attest.practice_informations
  end

  def get_data

    if params[:page_tab] == 'practitioner_info'
      @provider_personal_information_credentialing_contact = @provider_personal_information.provider_personal_information_credentialing_contact
      @provider_personal_information_credentialing_contact ||= @provider_personal_information.build_provider_personal_information_credentialing_contact.save

      @provider_personal_information_confidential_contact = @provider_personal_information.provider_personal_information_confidential_contact
      @provider_personal_information_confidential_contact ||= @provider_personal_information.build_provider_personal_information_confidential_contact.save
    end

    if params[:page_tab] == 'education_record'
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
      @q = School.ransack(params[:q])
      @practice_information_education = PracticeInformationEducation.find_or_initialize_by(id: params[:practice_information_education_id], provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id)
    end

    if params[:page_tab] == 'board_cert'
      @provider_specialties = ProviderSpecialty.where(provider_attest_id: @provider_personal_information.provider_attest_id)
    end

    if params[:page_tab] == 'board_cert_info'
      @provider_specialty = ProviderSpecialty.find_or_initialize_by(id: params[:provider_specialty_id], provider_attest_id: @provider_personal_information.provider_attest_id)
      if @provider_specialty.persisted?
        @provider_personal_information_comment = ProviderPersonalInformationComment.new
        @provider_personal_information_comments = ProviderPersonalInformationComment.all
      end
    end

    # Common logic for handling nested associations
    # Common logic for handling nested associations
    def build_associations(practice_information)
      [
        :allied_health_practitioners,
        :personally_employed_practitioners,
        :licensed_members,
        :staff_spoken_foreign_languages,
        :provider_anesthesia_administrations,
        :covering_practitioners
      ].each do |association|
        practice_information.send(association).build if practice_information.send(association).empty?
      end
    end

    if params[:page_tab] == 'practice_info'
      @q = PracticeInformation.ransack(params[:q])
      @practice_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @url = mhc_practice_informations_path
    end

    if ['add_practice_info', 'edit_practice_info', 'practice_info_record'].include?(params[:page_tab])
      # Determine if it's a new or existing practice information
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @practice_information = if params[:page_tab] == 'add_practice_info'
                                PracticeInformation.new(
                                  provider_attest_id: @provider_personal_information.provider_attest_id,
                                  caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id
                                )
                              else
                                PracticeInformation.find_or_initialize_by(
                                  id: params[:practice_information_id],
                                  provider_attest_id: @provider_personal_information.provider_attest_id,
                                  caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id
                                )
                              end

      # Build associations if necessary
      build_associations(@practice_information)

      # Set @url based on specific tab
      case params[:page_tab]
      when 'add_practice_info'
        @url = mhc_practice_informations_path  # Assign URL for adding new practice info
      when 'edit_practice_info'
        @url = mhc_practice_information_path(@practice_information)  # Edit path for existing practice info
      when 'practice_info_record'
        @url = mhc_practice_information_path(@practice_information)
      end
    end

    if params[:page_tab] == 'education'
      @q = @provider_personal_information.provider_attest.practice_information_educations.ransack(params[:q]&.except(:page_tab))
      @practice_information_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'training'
      @q = @provider_personal_information.provider_attest.provider_educations.ransack(params[:q]&.except(:page_tab))
      @provider_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'training_record'
      @q = School.ransack(params[:q])
      @provider_education = ProviderEducation.find_or_initialize_by(id: params[:provider_education_id], provider_attest_id: @provider_personal_information.provider_attest_id)
      if @provider_education.persisted?
        @provider_personal_information_comment = ProviderPersonalInformationComment.new
        @provider_personal_information_comments = ProviderPersonalInformationComment.all
      end
    end

    if params[:page_tab] == 'sam'
      @provider_personal_information_sam_records = @provider_personal_information.provider_personal_information_sam_records
    end

    if params[:page_tab] == 'sam_record'
      @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.find(params[:provider_personal_information_sam_record_id])
    end

    if params[:page_tab] == 'add_new_sam'
      @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.new(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'oig'
      @provider_personal_information_reinstatements = ProviderPersonalInformationReinstatement.where(provider_personal_information_id:  @provider_personal_information.id)
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
    end

    if params[:page_tab] == 'add_oig_info'
      @provider_personal_information_reinstatement = ProviderPersonalInformationReinstatement.new(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'show_sam_record'
      @provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.find_or_initialize_by(id: params[:provider_personal_information_sam_rva_record_id], provider_personal_information_sam_record_id: params[:provider_personal_information_sam_record_id])
    end

    if params[:page_tab] == 'registration'
      @provider_deas = @provider_personal_information.provider_deas.order(:id)
      @states = State.all
    end

    if params[:page_tab] == 'liability'
      @q = ProviderInsuranceCoverage.ransack(params[:q])
      @provider_insurance_coverages = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @states = State.all
      @limit = 10 # Set limit
      @total_pages = (@provider_insurance_coverages_count.to_f / @limit.to_f).ceil
    end

    if params[:page_tab] == 'add_new_liability'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      if params[:coverage_id].present?
        @provider_insurance_coverage = ProviderInsuranceCoverage.find(params[:coverage_id])
      else
        @provider_insurance_coverage = ProviderInsuranceCoverage.new(provider_attest_id: @provider_attest_id)
      end
    end

    if params[:page_tab] == 'liability_info'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_insurance_coverages = ProviderInsuranceCoverage.find(params[:coverage_id])
    end

    if params[:page_tab] == 'npdb'
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_npdb = ProviderNpdb.find_or_initialize_by(
        provider_attest_id: @provider_attest_id,
        caqh_provider_attest_id: @provider_personal_information&.caqh_provider_attest_id
      )
    end

    if params[:page_tab] == 'app_tracking'
      @provider_personal_information_app_trackings = ProviderPersonalInformationAppTracking.where(provider_personal_information_id: @provider_personal_information.id).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'app_tracking_record'
      @provider_personal_information_app_tracking = ProviderPersonalInformationAppTracking.where(id: params[:provider_personal_information_app_tracking_id]).first_or_initialize(provider_personal_information_id: @provider_personal_information.id)
      @provider_information_names = ProviderPersonalInformation
        .select(:nid, "CONCAT(last_name,', ',first_name, ' ', middle_name) as name")
        .all.collect { |provider_personal_information| [provider_personal_information.name, provider_personal_information.nid] }
      @selected_issues = @provider_personal_information_app_tracking.master_issues
      @selected_reviews = @provider_personal_information_app_tracking.master_reviews
    end

    # code for licensure tab
    if %w[edit_licensure license_record].include?(params[:page_tab])
      @provider_licensure = ProviderLicensure.find(params[:licensure_id])
    end

    case params[:page_tab]
    when "licensure"
      @q = ProviderLicensure.ransack(params[:q])
      @provider_licensures = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @limit = 10
      @total_pages = (@provider_insurance_coverages_count.to_f / @limit.to_f).ceil

    when "add_new_licensure"
      if @provider_personal_information
        @provider_attest_id = @provider_personal_information.provider_attest_id
        caqh_provider_attest_id = @provider_personal_information.caqh_provider_attest_id
      end

      @provider_licensure = ProviderLicensure.new(
        provider_attest_id: @provider_attest_id,
        caqh_provider_attest_id: caqh_provider_attest_id
      )
      @provider_licensure.provider_supervisings.build if @provider_licensure.provider_supervisings.empty?
      @url = mhc_provider_licensures_path

    when "edit_licensure"
      @url = mhc_provider_licensure_path

    when "license_record"
      # @provider_licensure is already set above
    end
  end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end
end
