class EnrollmentClientsController < ApplicationController
  before_action :set_providers, only: [:index, :download_documents, :show, :reports, :dashboard]
  before_action :set_provider, only: [:show]
  before_action :set_incomplete_providers, only: [:show, :index, :reports, :notifications, :dashboard]

  def index; end

  def show
    if params[:mode].present?
        if @provider
          @show_missing_fields = @provider.show_missing_fields?
          @provider.build_licenses if @provider.licenses.nil?
        end
      render params[:mode]
    end
    set_comment
  end

  def reports;end

  def notifications
    @provider = if params[:provider_id]
      Provider.find(params[:provider_id])
    else
      @incomplete_providers.first
    end

    if @provider
      @show_missing_fields = @provider.show_missing_fields?
      @provider.build_licenses if @provider.licenses.nil?
    end
    set_comment
  end

  def providers_to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Provider Status", "Client", "Location", "First Name", "Middle Name", "Last Name", "Practitioner Type", "NPI", "Practitioner SSN"]

      @providers.each do |provider|
        csv << [
          "",
          provider&.client&.group_name,
          provider&.location&.dco_name,
          provider&.first_name,
          provider&.middle_name,
          provider&.last_name,
          provider&.practitioner,
          provider&.npi,
          provider&.ssn
        ]
      end
    end
  end

  def download_documents
    @month = params[:month].present? ? DateTime.parse(params[:month].split("-").join("/")) : nil
  
    respond_to do |format|
      format.csv { send_data eval("#{params[:template]}_to_csv"), filename: csv_filename }
    end
  end

  def dashboard
    if current_user.can_access_all_groups? || current_user.super_administrator?
      @providers_with_missing_details ||= Provider.with_missing_required_fields.count
      @providers_with_missing_documents ||= Provider.with_missing_required_docs.count
    else
      @providers_with_missing_details ||= Provider.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).with_missing_required_fields.count
      @providers_with_missing_documents ||= Provider.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).with_missing_required_docs.count
    end
  end

  def groups
    if current_user.can_access_all_groups? || current_user.super_administrator?
      @enrollment_groups = EnrollmentGroup.search_by_params(params)
    else
      @enrollment_groups = current_user.enrollment_groups.search_by_params(params)
    end
  end

  def view_group
    @states = State.all
    @view_only = true
		@enrollment_group = EnrollmentGroup.find params[:group_id]

		if @enrollment_group.contact_personnels.blank?
			@enrollment_group.contact_personnels.build
		end

		if @enrollment_group.details.blank?
			@enrollment_group.details.build
		end

		@enrollment_group.qualifacts_contacts.build if current_setting.qualifacts? && !@enrollment_group.qualifacts_contacts.present?

		render 'enrollments/new_group'
  end

  protected

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def set_providers
    @providers = Provider.all

    if current_user.accessible_provider.present?
      @providers = @providers.where(id: current_user.accessible_provider)
    end

    @providers = @providers.search_by_params(params)

    # this will need refactoring just went with this for now for hotfix
    if !params[:enrollment_status].blank?
    # render json: params and return
      status_ids = EnrollmentProvidersDetail.where(enrollment_status: params[:enrollment_status]).pluck(:enrollment_provider_id)
      provider_ids = @providers.joins(enrollments: :details)
                                       .where(enrollment_providers: { id: status_ids }).pluck(:id)
      @providers = Provider.where(id: provider_ids)
    end

    if !current_user.can_access_all_groups? && !current_user.super_administrator?
      enrollment_group_filter = current_user.enrollment_groups.present? ? "enrollment_group_id IN (#{current_user.enrollment_groups.pluck(:id).map{|s| "'#{s.to_s}'"}.join(',')})" : nil
      accessible_provider_filter = current_user.accessible_provider.present? ? "id = #{current_user.accessible_provider}" : nil
      if enrollment_group_filter.present? && accessible_provider_filter.present?
        enrollment_group_filter += " OR "
      end

      @providers = @providers.where("#{enrollment_group_filter}#{accessible_provider_filter}")
    end

    @providers = @providers.paginate(per_page: 50, page: params[:page] || 1)
    # @providers = Provider.search_by_params(params).paginate(per_page: 50, page: params[:page] || 1)
  end

  def set_incomplete_providers
    @incomplete_providers = Provider.search_by_params(params).with_missing_required_attributes
    if params[:name].present?
      @incomplete_providers = @incomplete_providers.search_name(params[:name])
    end

    if params[:missing_field].present?
      # @incomplete_providers = @incomplete_providers.filter_by_missing_field(params[:missing_field])

      @incomplete_providers = (params[:missing_field]  == 'missing_documents' ? @incomplete_providers.with_missing_documents : @incomplete_providers.with_missing_field_fields)
    end

    if !current_user.can_access_all_groups? && !current_user.super_administrator?
      enrollment_group_filter = current_user.enrollment_groups.present? ? "providers.enrollment_group_id IN (#{current_user.enrollment_groups.pluck(:id).map{|s| "'#{s.to_s}'"}.join(',')})" : nil
      accessible_provider_filter = current_user.accessible_provider.present? ? "providers.id = #{current_user.accessible_provider}" : nil
      if enrollment_group_filter.present? && accessible_provider_filter.present?
        enrollment_group_filter += " OR "
      end

      @incomplete_providers = @incomplete_providers.where("#{enrollment_group_filter}#{accessible_provider_filter}")
    end
    @incomplete_providers = @incomplete_providers.paginate(per_page: 50, page: params[:page] || 1)
  end

  def set_comment
    @comment = EnrollmentComment.new
    @comment.provider = @provider
    @comment.user = current_user
  end

  def provider_submitted_enrollments_to_csv
    enrollment_details = EnrollmentProvidersDetail.where(enrollment_status: 'application-submitted').where(start_date: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "Providers First Name", "Providers Last Name", "Practitioner Type", "NPI", "Payor", "Enrollment Type", "State", "Initial Application Status", "Date Initial Application Submitted", "Provider ID"]

      enrollment_details.each do |enrollment_detail|
        csv << [
          flatforms.detect{|flatform| flatform.last == enrollment_detail.enrollment_provider&.provider&.group&.flatform }&.first,
          enrollment_detail.enrollment_provider&.provider&.group&.group_name,
          enrollment_detail.enrollment_provider&.provider&.first_name,
          enrollment_detail.enrollment_provider&.provider&.last_name,
          enrollment_detail.enrollment_provider&.provider&.practitioner_type,
          format_number_for_leading_zeroes(enrollment_detail.enrollment_provider&.provider&.npi),
          enrollment_detail.enrollment_payer,
          format_number_for_leading_zeroes(enrollment_detail.enrollment_type),
          enrollment_detail.payer_state,
          enrollment_detail.enrollment_status,
          enrollment_detail.start_date,
          enrollment_detail.provider_id,
        ]
      end
    end
  end

  def group_submitted_enrollments_to_csv
    enrollment_details = EnrollGroupsDetail.includes(:application_status_logs).where(application_status: 'application-submitted').where(application_status_logs: { created_at: @month.beginning_of_month..@month.end_of_month })
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "Payor Name", "Group ID", "Application Status", "State", "Initial Application Submitted Date",]
      enrollment_details.each do |enrollment_detail|
        csv << [
          flatforms.detect{|flatform| flatform.last == enrollment_detail.enroll_group&.group&.flatform }&.first,
          enrollment_detail.enroll_group&.group&.group_name,
          enrollment_detail.enrollment_payer,
          enrollment_detail.enroll_group_id,
          enrollment_detail.application_status,
          enrollment_detail.payer_state,
          enrollment_detail.application_status_logs&.where(status: 'application-submitted').where(created_at: @month.beginning_of_month..@month.end_of_month)&.last&.created_at&.strftime('%b %d, %Y'),
          format_number_for_leading_zeroes(enrollment_detail.enroll_group&.group&.npi_digit_type),
        ]
      end
    end
  end

  def license_report_to_csv
    providers = Provider.includes(:licenses, :cnp_licenses, :rn_licenses).where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", "State License Number","State License Effective date", "State License Expiration", "Advance Practice Registered Nurse License License Number",
               "State", "Advance Practice Registered Nurse License Effective Date",
              "Advance Practice Registered Nurse License Expiration Date", "Registered Nurse License Number", "State", "Registered Nurse Effective Date", "Registered Nurse Expiration Date", "Certification Name", "Board Certification Number", "Effective Date", "Re-cretification Date"
              ]
      providers.each do |provider|
        licenses = provider.licenses
        cnp_licenses = provider.cnp_licenses
        rn_licenses = provider.rn_licenses
        board_certifications = provider.board_certifications
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.state_id,
          format_number_for_leading_zeroes(licenses.pluck(:license_number).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(licenses.pluck(:license_state_renewal_date).reject {|i| !i.present? }),
          licenses.pluck(:license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_number).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:state_id).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_renewal_effective_date).reject {|i| !i.present? }),
          cnp_licenses.pluck(:expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_number).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(rn_licenses.pluck(:state_id).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_renewal_effective_date).reject {|i| !i.present? }),
          rn_licenses.pluck(:rn_license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(board_certifications.pluck(:bc_board_name).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(board_certifications.pluck(:bc_certification_number).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(board_certifications.pluck(:bc_effective_date).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(board_certifications.pluck(:bc_recertification_date).reject {|i| !i.present? }),
        ]
      end
    end
  end

  def dea_to_csv
    providers = Provider.includes(:dea_licenses).where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "DEA Number", "DEA State", "DEA Effective Date",
              "DEA Expiration Date",]
      providers.each do |provider|
        dea_licenses = provider.dea_licenses
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          format_number_for_leading_zeroes(dea_licenses.pluck(:dea_license_number).reject {|i| !i.present? }),
          State.where(id: dea_licenses.pluck(:state_id)).pluck(:name).join(", "),
          dea_licenses.pluck(:dea_license_renewal_effective_date).reject {|i| !i.present? }.collect { |i| Date.parse(i).strftime('%b %d, %Y') }.join(", "),
          dea_licenses.pluck(:dea_license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
        ]
      end
    end
  end

  def caqh_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", "CAQH ID", "Attestation", "Reattestation"]
      providers.each do |provider|
        caqh_state = provider&.caqh_state
        state_id = caqh_state.to_i
        state_name = State.find_by(id: state_id)&.name
        caqh_reattest_completed_by = Date.parse(provider&.caqh_reattest_completed_by)&.strftime('%b %d, %Y') rescue nil
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          state_name,
          format_number_for_leading_zeroes(provider.caqhid),
          provider.caqh_current_reattestation_date&.strftime('%b %d, %Y'),
          caqh_reattest_completed_by
        ]
      end
    end
  end
  def oig_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", "OIG  Status", " Source Date", " Verification Date", "OIG Status", "OIG Verification Date", "OIG Source Date",]
      providers.each do |provider|
        caqh_reattest_completed_by = Date.parse(provider&.caqh_reattest_completed_by)&.strftime('%b %d, %Y') rescue nil
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.state_id,
          "",
          provider.caqh_current_reattestation_date&.strftime('%b %d, %Y'),
          caqh_reattest_completed_by
        ]
      end
    end
  end
  def sam_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", " Source Date", " Verification Date",]
      providers.each do |provider|
        caqh_reattest_completed_by = Date.parse(provider&.caqh_reattest_completed_by)&.strftime('%b %d, %Y') rescue nil
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.state_id,
          provider.caqh_current_reattestation_date&.strftime('%b %d, %Y'),
          caqh_reattest_completed_by,
          format_number_for_leading_zeroes(provider.caqhid),
        ]
      end
    end
  end
  def missing_items_report_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "State", "First Name","Middle Name", "Last Name", "Practitioner Type", "NPI", "Tax ID", "Missing Information",]
      providers.each do |provider|
        caqh_reattest_completed_by = Date.parse(provider&.caqh_reattest_completed_by)&.strftime('%b %d, %Y') rescue nil
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.state_id,
          provider.first_name,
          provider.middle_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          format_number_for_leading_zeroes(provider.caqhid),
          provider.welcome_letter_message,
          provider.caqh_current_reattestation_date&.strftime('%b %d, %Y'),
          caqh_reattest_completed_by
        ]
      end
    end
  end

  def liability_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", "Policy Number","Effective Date", "Expiration Date"]
      providers.each do |provider|
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.state_id,
          provider.prof_liability_policy_number,
          provider.provider_effective_date,
          provider.prof_liability_expiration_date&.strftime('%b %d, %Y')
        ]
      end
    end
  end

  def enrollment_details_report_to_csv
    enrollment_details = EnrollmentProvidersDetail.includes(:application_status_logs, enrollment_provider: :provider)
    if @month.present?
      enrollment_details = enrollment_details.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Group", "Provider Last Name", "Provider First Name", "Enrollment Type", "Payor Name", "Notification of New Provider",
              "Date Group Notification of Provider (Welcome Letter)", "Date Notification to begin submitting enrollment (Contract signed/Profile/Documents Complete)", " Payor",
              "Enrollment Type", "State", "Initial Application Status", "Date Initial Application Submitted", "Effective Date", "Provider ID", "Most Current Revalidation Date", "Revalidation Next Due Date", "Notes",]
      enrollment_details.each do |enrollment_detail|
        provider = enrollment_detail.enrollment_provider&.provider
        missing_fields = []
        provider&.required_fields.each do |field|
          if (provider&.send(field[1]).nil? || provider&.send(field[1]).blank?) && !provider&.submitted_missing_fields.include?(field[1])
            missing_fields.push(field[0])
          end
        end
        if !provider&.licenses&.any?(&:persisted?) || provider&.has_missing_state_licenses_fields?
          provider&.required_state_licenses_fields.each do |field|
            if !provider&.submitted_missing_fields.include?(field[1])
              missing_fields.push(field[0])
            end
          end
        end
        csv << [
          provider&.group&.group_name,
          provider&.last_name,
          enrollment_detail.enrollment_provider&.provider.first_name,
          enrollment_detail.enrollment_type,
          enrollment_detail.enrollment_payer,
          provider&.new_provider_notification,
          provider&.welcome_letter_sent,
          provider&.notification_enrollment_submit,
          enrollment_detail.payor_username,
          enrollment_detail.enrollment_type,
          enrollment_detail.payer_state,
          enrollment_detail.enrollment_status,
          enrollment_detail.application_status_logs&.where(status: 'application-submitted')&.last&.created_at&.strftime('%b %d, %Y'),
          enrollment_detail.enrollment_effective_date,
          enrollment_detail.provider_id,
          enrollment_detail.revalidation_date,
          enrollment_detail.revalidation_due_date,
          enrollment_detail.comment,
        ]
      end
    end
  end

  def group_detail_report_to_csv
    enrollment_details = EnrollGroupsDetail.includes(enroll_group: :group)
    if @month.present?
      enrollment_details = enrollment_details.where(enroll_groups: { created_at: @month.beginning_of_month..@month.end_of_month })
    end
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "Notification of New Group", "Date Notification to begin submitting enrollment(Contract signed/Profile/Documents Complete)",
              "Payor Name", "Group Id", "Enrollment Type", "State", "Application Status", "Initial Effective Date", "Most Current Revalidation Date", "Line of Services", "Notes"]
      enrollment_details.each do |enrollment_detail|
        enroll_group = enrollment_detail.enroll_group
        group = enroll_group&.group
        csv << [
          flatforms.detect{|flatform| flatform.last == group&.flatform }&.first,
          group&.group_name,
          group&.new_group_notification&.strftime('%b %d, %Y'),
          group&.notification_enrollment_submit_group&.strftime('%b %d, %Y'),
          enrollment_detail.enrollment_payer,
          enrollment_detail.enroll_group_id,
          enrollment_detail.payor_submission_type,
          enrollment_detail.payer_state,
          application_statuses.detect{|application_status| application_status.last == enrollment_detail.application_status }&.first,
          enrollment_detail.effective_date&.strftime('%b %d, %Y'),
          enrollment_detail.revalidation_date&.strftime('%b %d, %Y'),
          enrollment_detail.payor_type,
          enrollment_detail.notes,
        ]
      end
    end
  end

  def group_revalidation_to_csv
    enrollment_details = EnrollGroupsDetail.includes(enroll_group: :group)
    enrollment_details = enrollment_details.where("enroll_groups_details.application_status = ?", 'approved') 
    if @month.present?
      enrollment_details = enrollment_details.where(enroll_group: { created_at: @month.beginning_of_month..@month.end_of_month })
    end
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "NPI", "(Payor)1", "State", "(Payor)\nProvider ID", "(Payor)\nProvider\nEffective Date",
              "(Payor)\nProvider\nRevalidation\nDate", "(Payor)2","State", "(Payor)\nProvider ID", "(Payor)\nProvider\nEffective Date",
              "(Payor)\nProvider\nRevalidation\nDate"]
      enrollment_details.each do |enrollment_detail|
        enroll_group = enrollment_detail.enroll_group
        group = enroll_group&.group
        csv << [
          flatforms.detect{|flatform| flatform.last == group&.flatform }&.first,
          group&.group_name,
          group&.npi_digit_type,
          enrollment_detail.enrollment_payer,
          enrollment_detail.payer_state,
          enrollment_detail.group_number,
          enrollment_detail.effective_date&.strftime('%b %d, %Y'),
          enrollment_detail.revalidation_date&.strftime('%b %d, %Y'),
          enrollment_detail.enrollment_payer,
          enrollment_detail.payer_state,
          enrollment_detail.group_number,
          enrollment_detail.effective_date&.strftime('%b %d, %Y'),
          enrollment_detail.revalidation_date&.strftime('%b %d, %Y'),
        ]
      end
    end
  end

  def termed_providers_to_csv
    providers = Provider.where(status: 'inactive-termed').where("(CAST(end_date AS DATE)) BETWEEN ? and ?", @month.beginning_of_month, @month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "Termed Date"]
      providers.each do |provider|
        end_date = Date.parse(provider.end_date)&.strftime('%b %d, %Y') rescue nil

        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          end_date
        ]
      end
    end
  end

  def new_profile_setup_in_one_app_to_csv
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Services", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "Date Profile Created in One App",]
      providers.each do |provider|

        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.notification_services,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.created_at&.strftime('%b %d, %Y'),
          provider.notes.pluck(:description).join(", ")
        ]
      end
    end
  end

  def flatforms
    @flatforms ||=  [['Credible','credible'], ['CareLogic','carelogic'], ['Insync','insync']]
  end

  def application_statuses
    @application_statuses ||=  [['Credible','credible'], ['CareLogic','carelogic'], ['Insync','insync']]
    [['Application Not Submitted','application-not-submitted'],['Application Submitted','application-submitted'],['Processing','processing'],['Approved','approved'],['Denied','denied'],['Terminated','terminated'],['Not Eligible','not-eligible'],['Revalidation','revalidation'],['Not Part of Contract','none-contract']]
  end

  # accepts Int, String and Array
  def format_number_for_leading_zeroes(value)
    return nil unless value.present?
    if value.is_a?(Array)
      if value.size > 1
        return value.collect { |i| i.to_s }.join(", ")
      else
        return value.collect { |i| '="' + "#{i.to_s}" + '"' }.join(", ")
      end
    else
      return '="' + "#{value.to_s}" + '"'
    end
  end
  private
  
  def csv_filename
    if @month.present?
      "#{params[:template]&.dasherize}-#{@month.strftime("%Y-%m")}.csv"
    else
      "#{params[:template]&.dasherize}-all.csv"
    end
  end
end
