class EnrollmentClientsController < ApplicationController
  before_action :set_providers, only: [:index, :download_documents, :show, :reports, :dashboard]
  before_action :set_provider, only: [:show]
  before_action :set_incomplete_providers, only: [:show, :index, :reports, :notifications, :dashboard, :groups]

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

  def reports
    @agents = User.where(user_role: 'agent')
  end

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
    selected_start_date = nil
    selected_end_date = nil

    if params[:daterange].present?
      start_date, end_date = params[:daterange].split(' - ')

      # Parse start and end dates from the date range string
      selected_start_date = DateTime.parse(start_date)
      selected_end_date = DateTime.parse(end_date)
    end

    respond_to do |format|
      if params[:template].to_i.to_s == params[:template] && User.exists?(params[:template])
        format.csv { send_data agent_report_to_csv(params[:template], selected_start_date, selected_end_date), filename: "agent_report_#{params[:template]}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv" }
      else
        format.csv { send_data eval("#{params[:template]}_to_csv"), filename: csv_filename }
      end
    end
  end

  # generate the csv of agent
  def agent_report_to_csv(agent_id, start_date, end_date)
    agent = User.find(agent_id)

    # Parse start and end dates if they are not already in DateTime format
    if params[:daterange].present?
      start_date = DateTime.parse(start_date) unless start_date.is_a?(DateTime)
      end_date = DateTime.parse(end_date) unless end_date.is_a?(DateTime)
    end

    # Filter audit logs by the selected date range
    audit_logs = if start_date && end_date
    # If both start and end dates are provided, filter by the specified range
      agent.audits.where(action: ['update'], created_at: start_date.beginning_of_day..end_date.end_of_day).order(created_at: :desc)
    else
      # If start and end dates are not provided, retrieve all audit logs for the agent
      agent.audits.where(action: ['update']).order(created_at: :desc)
    end


    report_count = 0

    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Agent Email", "Action", "Time", "Report Count", "Report Generation Date"]

      audit_logs.each do |log|
        action = log.audited_changes["logout_on_close"] ? "Logged out on close" : "Logged in"
        csv << [
          agent.email,
          action,
          log.created_at.strftime('%b %d, %Y %H:%M:%S'),
          (report_count += 1),
          Time.now.strftime('%b %d, %Y %H:%M:%S')
        ]
      end
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
    enrollment_details = EnrollmentProvidersDetail.includes(enrollment_provider: [provider: :group])
                              .where(enrollment_status: 'application-submitted')
                              .where(start_date: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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
    enrollment_details = EnrollGroupsDetail.includes(:application_status_logs, enroll_group: :group).where(application_status: 'application-submitted').where(application_status_logs: { created_at: @month.beginning_of_month..@month.end_of_month })
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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

  def qualifacts_inventory_to_csv
    if current_user.can_access_all_groups? || current_user.super_administrator?
      @enrollment_groups = EnrollmentGroup.all
    else
      @enrollment_groups = current_user.enrollment_groups.search_by_params(params)
    end

    if @month.present?
      @enrollment_groups = @enrollment_groups.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end

    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Status", "Group", "Taxonomy Code", "State", "Number of Locations", "Number of Providers",]
      @enrollment_groups.each do |enrollment_group|
        csv << [
          flatforms.detect{|flatform| flatform.last == enrollment_group.flatform }&.first,
          group_statuses.to_h.key(enrollment_group.noti_status),
          enrollment_group.group_name,
          enrollment_group.group_code,
          enrollment_group.state,
          enrollment_group.dco_count_display,
          "#{enrollment_group.providers&.count} Provider(s)"
        ]
      end
    end
  end

  def qualifacts_enrollment_report_to_csv
    enrollment_details = EnrollmentProvidersDetail.includes(:application_status_logs, enrollment_provider: [provider: :group])
    if @month.present?
      enrollment_details = enrollment_details.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Group", "Provider Last Name", "Provider First Name", "Enrollment Type", "Payor Name", "State" , "Initial Application Status",
              "Date Initial Application Submitted", "Effective Date", "Provider ID", "Most Current Revalidation Date", "Revalidation Next Due Date", "Last Attempt Date", "Notes"]

      enrollment_details.each do |enrollment_detail|
        provider = enrollment_detail.enrollment_provider&.provider
        enrollment_effective_date = Date.parse(enrollment_detail.enrollment_effective_date)&.strftime('%b %d, %Y') rescue nil
        csv << [
          provider&.group&.group_name,
          provider&.last_name,
          provider&.first_name,
          enrollment_detail.enrollment_type,
          enrollment_detail.enrollment_payer,
          enrollment_detail.payer_state,
          enrollment_status.to_h.key(enrollment_detail.enrollment_status),
          enrollment_detail.start_date&.strftime('%b %d, %Y'),
          enrollment_effective_date,
          enrollment_detail.provider_id,
          enrollment_detail.revalidation_date&.strftime('%b %d, %Y'),
          enrollment_detail.revalidation_due_date&.strftime('%b %d, %Y'),
          "",
          enrollment_detail.comment,
        ]
      end
    end
  end

  def license_report_to_csv
    providers = Provider.includes(:licenses, :cnp_licenses, :rn_licenses, :group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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
          state_names_p = State.where(id: licenses.pluck(:state_id).reject(&:blank?)).pluck(:name).join(', '),
          format_number_for_leading_zeroes(licenses.pluck(:license_number).reject {|i| !i.present? }),
          format_number_for_leading_zeroes(licenses.pluck(:license_state_renewal_date).reject {|i| !i.present? }),
          licenses.pluck(:license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_number).reject {|i| !i.present? }),
          state_names = State.where(id: cnp_licenses.pluck(:state_id).reject(&:blank?)).pluck(:name).join(', '),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_renewal_effective_date).reject {|i| !i.present? }),
          cnp_licenses.pluck(:expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_number).reject {|i| !i.present? }),
          state_names_rn = State.where(id: rn_licenses.pluck(:state_id).reject(&:blank?)).pluck(:name).join(', '),
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
    providers = Provider.includes(:dea_licenses, :group)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    if @month.present?
      providers = providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
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
    providers = Provider.includes(:group)
    if @month.present?
      providers = providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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
    providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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
    providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
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
    providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "State", "First Name","Middle Name", "Last Name", "Practitioner Type", "NPI", "Tax ID", "Missing Information",]
      providers.each do |provider|
        state_id = provider&.state_id
        state_id = state_id.to_i
        state_name = State.find_by(id: state_id)&.name
        board_certifications = provider.board_certifications
        dea_licenses = provider.dea_licenses
        cds_licenses = provider.cds_licenses
        rn_licenses = provider.rn_licenses
        cnp_licenses = provider.cnp_licenses
        licenses = provider.licenses
        missing_information = []

        # Check each attribute for missing values and add to the missing_information array
        missing_information << "Status" if provider.status.blank?
        missing_information << "Gender" if provider.gender.blank?
        missing_information << "SSN" if provider.ssn.blank?
        missing_information << "Date of Birth" if provider.birth_date.blank?
        missing_information << "Birth City" if provider.birth_city.blank?
        missing_information << "Birth State" if provider.birth_state.blank?
        missing_information << "Address 1" if provider.address_line_1.blank?
        missing_information << "Address 2" if provider.address_line_2.blank?
        missing_information << "city" if provider.city.blank?
        missing_information << "State" if provider.state&.name.blank?
        missing_information << "Zip code" if provider.zip_code.blank?
        missing_information << "Phone Number" if provider.formatted_phone.blank?
        missing_information << "Email" if provider.email_address.blank?
        missing_information << "Notification of New Provider" if provider.new_provider_notification.blank?
        missing_information << "Start Date" if provider.notification_start_date.blank?
        missing_information << "Notification to begin submitting Enrollment" if provider.notification_enrollment_submit.blank?
        missing_information << "Services" if provider.notification_services.blank?
        missing_information << "status" if provider.status.blank?
        missing_information << "Work End Date" if provider.end_date.blank?
        missing_information << "Subject" if provider.welcome_letter_subject.blank?
        missing_information << "Upload files from computer" if provider.welcome_letter_attachments.blank?
        missing_information << "First Name" if provider.first_name.blank?
        missing_information << "Middle Name" if provider.middle_name.blank?
        missing_information << "Last Name " if provider.last_name.blank?
        missing_information << "Suffix" if provider.suffix.blank?
        missing_information << "Telephone Number" if provider.telephone_number.blank?
        missing_information << "Ext" if provider.ext.blank?
        missing_information << "Name of U.S./Canadian School" if provider.medical_school_name.blank?
        missing_information << "Start Date" if provider.prof_medical_start_date.blank?
        missing_information << "Degree Awarded" if provider.prof_medical_school_degree_awarded.blank?
        missing_information << "End(Graduation) Date" if provider.graduation_date.blank?
        missing_information << "Did you complete your graduate education at this school?" if provider.medical_license.blank?
        missing_information << "Practitioner Type (can be multiple)" if provider.practitioner_type.blank?
        missing_information << "Taxonomy" if provider.taxonomy.blank?
        missing_information << "Specialty (i.e., Specialties is selected based on taxonomy codes) (can be multiple)" if provider.specialty.blank?
        missing_information << "Provider Effective Date" if provider.provider_effective_date.blank?
        missing_information << "NPI Number" if provider.npi.blank?
        missing_information << "CAQH ID" if provider.caqhid.blank?
        missing_information << "CAQH State" if provider.caqh_state.blank?
        missing_information << "CAQH Username" if provider.caqh_username.blank?
        missing_information << "CAQH Password" if provider.caqh_password.blank?
        missing_information << "Current Re-Attestation" if provider.caqh_current_reattestation_date.blank?
        missing_information << "Re-Attestation must be completed by" if provider.caqh_reattest_completed_by.blank?
        missing_information << "Questions" if provider.caqh_question.blank?
        missing_information << "Answer" if provider.caqh_answer.blank?
        missing_information << "CAQH PDF Date Received" if provider.caqh_pdf_date_received.blank?
        missing_information << "CAQH Notes" if provider.caqh_notes.blank?
        missing_information << "Carrier or Self-Insured Name" if provider.prof_liability_carrier_name.blank?
        missing_information << "Self-Insured?" if provider.prof_liability_self_insured.blank?
        missing_information << "Professional Liability Address" if provider.prof_liability_address.blank?
        missing_information << "Professional Liability City" if provider.prof_liability_city.blank?
        missing_information << "Professional Liability State" if provider.prof_liability_state_id.blank?
        missing_information << "Professional Liability Zip Code (+4 Zip Code)" if provider.prof_liability_zipcode.blank?
        missing_information << "Original Effective Date" if provider.prof_liability_orig_effective_date.blank?
        missing_information << "Professional Liability Effective Date" if provider.prof_liability_effective_date.blank?
        missing_information << "Professional Liability Expiration Date" if provider.prof_liability_expiration_date.blank?
        missing_information << "Type of Coverage" if provider.prof_liability_coverage_type.blank?
        missing_information << "Do you have unlimited coverage with this insurance carrier?" if provider.prof_liability_unlimited_coverage.blank?
        missing_information << "Policy includes tail coverage?" if provider.prof_liability_tail_coverage.blank?
        missing_information << "Amount of coverage per occurence (must be at least $1,000,000/$3,000,000)" if provider.prof_liability_coverage_amount.blank?
        missing_information << "Amount of coverage aggregate (must be at least $1,000,000/$3,000,000)" if provider.prof_liability_coverage_amount_aggregate.blank?
        missing_information << "Policy Number" if provider.prof_liability_policy_number.blank?
        missing_information << "Group" if provider.enrollment_group_id.blank?
        missing_information << "Primary Location" if provider.primary_location.blank?
        missing_information << "Additional Locations" if provider.dcos.blank?
        missing_information << "Hire date of provider seeing patients" if provider.provider_hire_date_seeing_patient.blank?
        missing_information << "Effective date of provider seeing patients" if provider.effective_date_seeing_patient.blank?
        missing_information << "Does provider require a collab/supervising provider?" if provider.supervised_by_psychologist.blank?
        missing_information << "Providers Name" if provider.supervising_name.blank?
        missing_information << "Providers NPI" if provider.supervising_npi.blank?
        missing_information << "Telehealth License Number" if provider.telehealth_license_number.blank?
        missing_information << "Licensed Registered State" if provider.licensed_registered_state_id.blank?
        missing_information << "State License Copies" if provider.state_license_copies.blank?
        missing_information << "Dea Copies" if provider.dea_copies.blank?
        missing_information << "W9 Form Copies download template here" if provider.w9_form_copies.blank?
        missing_information << "Certificate Insurance Copies" if provider.certificate_insurance_copies.blank?
        missing_information << "Driver License Copies" if provider.driver_license_copies.blank?
        missing_information << "Board Certification Copies" if provider.board_certification_copies.blank?
        missing_information << "Caqh App Copies" if provider.caqh_app_copies.blank?
        missing_information << "Curriculum Vitae (CV) Copies" if provider.cv_copies.blank?
        missing_information << "Telehealth License Copies" if provider.telehealth_license_copies.blank?
        missing_information << "Board Certificate" if provider.school_certificate.blank?
        formatted_board_names = format_number_for_leading_zeroes(board_certifications.pluck(:bc_board_name).reject(&:blank?))
        missing_information << "Board Names" unless formatted_board_names.present?
        certification_number = format_number_for_leading_zeroes(board_certifications.pluck(:bc_certification_number).reject(&:blank?))
        missing_information << "Board Certification Number" unless certification_number.present?
        effective_date = format_number_for_leading_zeroes(board_certifications.pluck(:bc_effective_date).reject(&:blank?))
        missing_information << "Board Effective Date" unless effective_date.present?
        bc_recertification_date = format_number_for_leading_zeroes(board_certifications.pluck(:bc_recertification_date).reject(&:blank?))
        missing_information << "Board Re-certification Date" unless bc_recertification_date.present?
        bc_expiration_date = format_number_for_leading_zeroes(board_certifications.pluck(:bc_expiration_date).reject(&:blank?))
        missing_information << "Board Expiration Date" unless bc_expiration_date.present?
        bc_specialty_type = format_number_for_leading_zeroes(board_certifications.pluck(:bc_specialty_type).reject(&:blank?))
        missing_information << "Board Specialty Type" unless bc_specialty_type.present?
        dea_license_number = format_number_for_leading_zeroes(dea_licenses.pluck(:dea_license_number).reject(&:blank?))
        missing_information << "DEA Registration Number" unless dea_license_number.present?
        dea_license_effective_date = format_number_for_leading_zeroes(dea_licenses.pluck(:dea_license_effective_date).reject(&:blank?))
        missing_information << "DEA Registration Original License Issue Date" unless dea_license_effective_date.present?
        state_id = format_number_for_leading_zeroes(dea_licenses.pluck(:state_id).reject(&:blank?))
        missing_information << "DEA Registration State" unless state_id.present?
        dea_license_expiration_date = format_number_for_leading_zeroes(dea_licenses.pluck(:dea_license_expiration_date).reject(&:blank?))
        missing_information << "DEA Registration Expiration Date" unless dea_license_expiration_date.present?
        dea_license_renewal_effective_date = format_number_for_leading_zeroes(dea_licenses.pluck(:dea_license_renewal_effective_date).reject(&:blank?))
        missing_information << "DEA Registration Renewal(Current Effective) Date" unless dea_license_renewal_effective_date.present?
        cds_license_number = format_number_for_leading_zeroes(cds_licenses.pluck(:cds_license_number).reject(&:blank?))
        missing_information << "CDS Registration Number" unless cds_license_number.present?
        cds_license_issue_date = format_number_for_leading_zeroes(cds_licenses.pluck(:cds_license_issue_date).reject(&:blank?))
        missing_information << "CDS Registration Original License Issue Date" unless cds_license_issue_date.present?
        state_id_cds = format_number_for_leading_zeroes(cds_licenses.pluck(:state_id).reject(&:blank?))
        missing_information << "CDS Registration State" unless state_id_cds.present?
        cds_license_expiration_date = format_number_for_leading_zeroes(cds_licenses.pluck(:cds_license_expiration_date).reject(&:blank?))
        missing_information << "CDS Registration Expiration Date" unless cds_license_expiration_date.present?
        cds_renewal_effective_date = format_number_for_leading_zeroes(cds_licenses.pluck(:cds_renewal_effective_date).reject(&:blank?))
        missing_information << "CDS Registration Renewal(Current Effective) Date" unless cds_renewal_effective_date.present?
        rn_license_number = format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_number).reject(&:blank?))
        missing_information << "RN License Number" unless rn_license_number.present?
        rn_license_effective_date = format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_effective_date).reject(&:blank?))
        missing_information << "RN Original License Issue Date" unless rn_license_effective_date.present?
        state_id_rn = format_number_for_leading_zeroes(rn_licenses.pluck(:state_id).reject(&:blank?))
        missing_information << "RN Registration State" unless state_id_rn.present?
        rn_license_renewal_effective_date = format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_renewal_effective_date).reject(&:blank?))
        missing_information << "RN License Renewal(Current Effective) Date" unless rn_license_renewal_effective_date.present?
        rn_license_expiration_date = format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_expiration_date).reject(&:blank?))
        missing_information << "RN License Expiration Date" unless rn_license_expiration_date.present?
        cnp_license_number = format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_number).reject(&:blank?))
        missing_information << "APRN License Number" unless cnp_license_number.present?
        effective_date_ar = format_number_for_leading_zeroes(cnp_licenses.pluck(:effective_date).reject(&:blank?))
        missing_information << "APRN Original License Issue Date" unless effective_date_ar.present?
        state_id_ar = format_number_for_leading_zeroes(cnp_licenses.pluck(:state_id).reject(&:blank?))
        missing_information << "APRN Registration State" unless state_id_ar.present?
        cnp_license_renewal_effective_date = format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_renewal_effective_date).reject(&:blank?))
        missing_information << "APRN License Renewal(Current Effective) Date" unless cnp_license_renewal_effective_date.present?
        expiration_date_ar = format_number_for_leading_zeroes(cnp_licenses.pluck(:expiration_date).reject(&:blank?))
        missing_information << "APRN License Expiration Date" unless expiration_date_ar.present?
        license_number_st = format_number_for_leading_zeroes(licenses.pluck(:license_number).reject(&:blank?))
        missing_information << "State License Number" unless license_number_st.present?
        license_effective_date_st = format_number_for_leading_zeroes(licenses.pluck(:license_effective_date).reject(&:blank?))
        missing_information << "Original License Issue Date" unless license_effective_date_st.present?
        state_id_st = format_number_for_leading_zeroes(licenses.pluck(:state_id).reject(&:blank?))
        missing_information << "State Registered" unless state_id_st.present?
        license_expiration_date_st = format_number_for_leading_zeroes(licenses.pluck(:license_expiration_date).reject(&:blank?))
        missing_information << "State License Expiration Date" unless license_expiration_date_st.present?
        license_state_renewal_date_st = format_number_for_leading_zeroes(licenses.pluck(:license_state_renewal_date).reject(&:blank?))
        missing_information << "State License Renewal(Current Effective) Date" unless license_state_renewal_date_st.present?
        license_type_st = format_number_for_leading_zeroes(licenses.pluck(:license_type).reject(&:blank?))
        missing_information << "License Type" unless license_type_st.present?
        missing_information << "Message" if provider.welcome_letter_message.blank?
        missing_information << "Send Welcome Letter to Provider" if provider.welcome_letter_status.blank?
        GroupDco.where(created_at: @month.beginning_of_month..@month.end_of_month).each do |dco|
          missing_information << "city(group)" if dco&.dco_city.blank?
          missing_information << "State(group)" if dco&.state.blank?
          missing_information << "Zip Code(group)" if dco&.dco_zipcode.blank?
          missing_information << "Phone Number (group)" if dco&.service_location_phone_number.blank?
          missing_information << "Fax Number(group)" if dco&.service_location_fax_number.blank?
          missing_information << "Panel Status to New Patients(group)" if dco&.panel_status_to_new_patients.blank?
          missing_information << "Panel Age Limits(group)" if dco&.panel_age_limit.blank?
          missing_information << "Include in Directory?(group)" if dco&.include_in_directory.blank?
      end
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          state_name,
          provider.first_name,
          provider.middle_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.group&.tin_digit,
          missing_information.join(', '),
        ]
      end
    end
  end

  def liability_to_csv
    providers = Provider.includes(:group)
    if @month.present?
      providers = providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State", "Policy Number","Effective Date", "Expiration Date"]
      providers.each do |provider|
        prof_liability_state_id = provider&.prof_liability_state_id
        state_id = prof_liability_state_id.to_i
        state_name = State.find_by(id: state_id)&.name
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          state_name,
          provider.prof_liability_policy_number,
          provider.prof_liability_effective_date,
          provider.prof_liability_expiration_date&.strftime('%b %d, %Y')
        ]
      end
    end
  end

  def provider_enrollment_details_report_to_csv
    enrollment_details = EnrollmentProvidersDetail.includes(:application_status_logs, enrollment_provider: [provider: :group])
    if @month.present?
      enrollment_details = enrollment_details.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Group", "Provider Last Name", "Provider First Name", "Enrollment Type", "Payor Name", "Notification of New Provider",
              "Date Group Notification of Provider (Welcome Letter)", "Date Notification to begin submitting enrollment (Contract signed/Profile/Documents Complete)", " Payor",
              "Enrollment Type", "State", "Initial Application Status", "Date Initial Application Submitted", "Effective Date", "Provider ID", "Most Current Revalidation Date", "Revalidation Next Due Date", "Notes",]
      enrollment_details.each do |enrollment_detail|
        provider = enrollment_detail.enrollment_provider&.provider

        csv << [
          provider&.group&.group_name,
          provider&.last_name,
          enrollment_detail.enrollment_provider&.provider&.first_name,
          enrollment_detail.enrollment_type,
          enrollment_detail.enrollment_payer,
          provider&.new_provider_notification,
          provider&.welcome_letter_sent,
          provider&.notification_enrollment_submit,
          enrollment_detail.payor_username,
          enrollment_detail.enrollment_type,
          enrollment_detail.payer_state,
          enrollment_detail.enrollment_status,
          enrollment_detail.start_date,
          enrollment_detail.enrollment_effective_date,
          enrollment_detail.provider_id,
          enrollment_detail.revalidation_date,
          enrollment_detail.revalidation_due_date,
          enrollment_detail.comment,
        ]
      end
    end
  end

  def daily_activity_detail_report_to_csv
    today = Date.today
    audit_trails = CustomAudit.where(created_at: today.beginning_of_day..today.end_of_day).order(created_at: :desc).select do |audit_trail|
      !audit_trail.empty_changes?
    end

    CSV.generate(headers: true) do |csv|
      csv << ["Source", "Source Type", "Action Taken", "Action By", "Date Created", "Changes"]

      audit_trails.each do |audit_trail|
        changes = audit_trail.dislay_changes.each_with_index.map do |changes, index|
          "#{index + 1}.) #{changes}"
        end.join("\n")

        csv << [
          audit_trail.display_source,
          audit_trail.auditable_type,
          audit_trail.action,
          audit_trail.user&.full_name,
          audit_trail.created_at.strftime("%m/%d/%Y"),
          changes
        ]
      end
    end
  end

  def qualifacts_modified_providers_to_csv
    enrollment_details = EnrollmentProvidersDetail.includes(:audits).where(audits: { created_at:  @month.beginning_of_month..@month.end_of_month })

    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Group", "Provider Last Name", "Provider First Name", "Enrollment Type", "Payor Name", "Notification of New Provider",
              "Date Group Notification of Provider (Welcome Letter)", "Date Notification to begin submitting enrollment (Contract signed/Profile/Documents Complete)", " Payor",
              "Enrollment Type", "State", "Initial Application Status", "Date Initial Application Submitted", "Effective Date", "Provider ID", "Most Current Revalidation Date", "Revalidation Next Due Date", "Notes", "Last Modification Date"]
      enrollment_details.each do |enrollment_detail|
        provider = enrollment_detail.enrollment_provider&.provider
        csv << [
          provider&.group&.group_name,
          provider&.last_name,
          enrollment_detail.enrollment_provider&.provider&.first_name,
          enrollment_detail.enrollment_type,
          enrollment_detail.enrollment_payer,
          provider&.new_provider_notification,
          provider&.welcome_letter_sent,
          provider&.notification_enrollment_submit,
          enrollment_detail.payor_username,
          enrollment_detail.enrollment_type,
          enrollment_detail.payer_state,
          enrollment_detail.enrollment_status,
          enrollment_detail.start_date,
          enrollment_detail.enrollment_effective_date,
          enrollment_detail.provider_id,
          enrollment_detail.revalidation_date,
          enrollment_detail.revalidation_due_date,
          enrollment_detail.comment,
          enrollment_detail.audits&.first&.created_at || enrollment_detail.updated_at
        ]
      end
    end
  end

  def provider_revalidation_report_to_csv
    @enrollment_details = EnrollmentProvidersDetail.includes(enrollment_provider: [provider: :group])
                              .where(enrollment_status: 'approved')
    if @month.present?
      @enrollment_details = @enrollment_details.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end

    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Group", "Provider Last Name", "Provider First Name", "Enrollment Type", "Payor Name", "Notification of New Provider",
      "Date Group Notification of Provider (Welcome Letter)", "Date Notification to begin submitting enrollment (Contract signed/Profile/Documents Complete)", " Payor",
      "Enrollment Type", "State", "Initial Application Status", "Date Initial Application Submitted", "Effective Date", "Provider ID", "Most Current Revalidation Date", "Revalidation Next Due Date", "Notes"]
      @enrollment_details.each do |enrollment_detail|
        provider = enrollment_detail.enrollment_provider&.provider

        csv << [
          provider&.group&.group_name,
          provider&.last_name,
          enrollment_detail.enrollment_provider&.provider&.first_name,
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
          enrollment_detail.comment
        ]
      end
    end
  end

  def group_detail_report_to_csv
    enrollment_details = EnrollGroupsDetail.includes(enroll_group: :group)
    if @month.present?
      enrollment_details = enrollment_details.where(enroll_groups: { created_at: @month.beginning_of_month..@month.end_of_month })
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
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
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
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
    sql_string = "SELECT a.*
          FROM  (SELECT to_date(end_date, 'YYYY-MM-DD') as end_date_timestamp, *
                  FROM providers
                  WHERE status = 'inactive-termed') as a
          INNER JOIN enrollment_groups ON enrollment_groups.id = a.enrollment_group_id
          WHERE a.end_date_timestamp BETWEEN '#{@month.beginning_of_month}' AND '#{@month.end_of_month}'"
    filter_by_group = ""
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      group_names = current_user&.enrollment_groups&.pluck(:group_name).compact
      if group_names
        filter_by_group = " AND enrollment_groups.group_name IN (#{group_names.map{|s| "'#{s.to_s}'"}.join(",")})"
      end
    end
    sql = <<-SQL
      #{sql_string + filter_by_group}
    SQL

    providers = Provider.find_by_sql(sql)
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
    providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["Platform", "Services", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "Date Profile Created in One App"]
      providers.each do |provider|

        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.notification_services,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          provider.created_at&.strftime('%b %d, %Y')
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
