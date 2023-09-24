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
    respond_to do |format|
      format.csv { send_data providers_to_csv, filename: "Providers.csv" }
    end
  end

  def download_documents
    @month = DateTime.parse(params[:month]&.split("-").join("/"))
    respond_to do |format|
      format.csv { send_data eval("#{params[:template]}_to_csv"), filename: "#{params[:template]&.dasherize}-#{params[:month]}.csv" }
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
    enrollment_details = EnrollmentProvidersDetail.includes(:application_status_logs).where(enrollment_status: 'application-submitted').where(application_status_logs: { created_at: @month.beginning_of_month..@month.end_of_month })
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "Providers First Name", "Providers Last Name", "Practitioner Type", "NPI", "Payor", "Enrollment Tracking ID", "Submission Date"]

      enrollment_details.each do |enrollment_detail|
        csv << [
          flatforms.detect{|flatform| flatform.last == enrollment_detail.enrollment_provider&.provider&.group&.flatform }&.first,
          enrollment_detail.enrollment_provider&.provider&.group&.group_name,
          enrollment_detail.enrollment_provider&.provider&.first_name,
          enrollment_detail.enrollment_provider&.provider&.last_name,
          enrollment_detail.enrollment_provider&.provider&.practitioner_type,
          format_number_for_leading_zeroes(enrollment_detail.enrollment_provider&.provider&.npi),
          enrollment_detail.enrollment_payer,
          format_number_for_leading_zeroes(enrollment_detail.enrollment_tracking_id),
          enrollment_detail.application_status_logs&.where(status: 'application-submitted').where(created_at: @month.beginning_of_month..@month.end_of_month)&.last&.created_at&.strftime('%b %d, %Y')
        ]
      end
    end
  end

  def group_submitted_enrollments_to_csv
    enrollment_details = EnrollGroupsDetail.includes(:application_status_logs).where(application_status: 'application-submitted').where(application_status_logs: { created_at: @month.beginning_of_month..@month.end_of_month })
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "NPI", "Payor", "Enrollment Tracking ID", "Submission Date"]
      enrollment_details.each do |enrollment_detail|
        csv << [
          flatforms.detect{|flatform| flatform.last == enrollment_detail.enroll_group&.group&.flatform }&.first,
          enrollment_detail.enroll_group&.group&.group_name,
          format_number_for_leading_zeroes(enrollment_detail.enroll_group&.group&.npi_digit_type),
          enrollment_detail.enrollment_payer,
          "",
          enrollment_detail.application_status_logs&.where(status: 'application-submitted').where(created_at: @month.beginning_of_month..@month.end_of_month)&.last&.created_at&.strftime('%b %d, %Y')
        ]
      end
    end
  end

  def license_report_to_csv
    providers = Provider.includes(:licenses, :cnp_licenses, :rn_licenses).where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true) do |csv|
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "State License Number", "State License Expiration",
              "NP License Number", "NP Expiration Date", "RN License Number", "RN Expiration Date", "NCCPA Number", "NCCPA Expiration", "NP Certification Number",
              "NP Certification Expiration"]
      providers.each do |provider|
        licenses = provider.licenses
        cnp_licenses = provider.cnp_licenses
        rn_licenses = provider.rn_licenses
        csv << [
          flatforms.detect{|flatform| flatform.last == provider.group&.flatform }&.first,
          provider.group&.group_name,
          provider.first_name,
          provider.last_name,
          provider.practitioner_type,
          format_number_for_leading_zeroes(provider.npi),
          format_number_for_leading_zeroes(licenses.pluck(:license_number).reject {|i| !i.present? }),
          licenses.pluck(:license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(cnp_licenses.pluck(:cnp_license_number).reject {|i| !i.present? }),
          cnp_licenses.pluck(:expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", "),
          format_number_for_leading_zeroes(rn_licenses.pluck(:rn_license_number).reject {|i| !i.present? }),
          rn_licenses.pluck(:rn_license_expiration_date).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", ")
        ]
      end
    end
  end

  def dea_to_csv
    providers = Provider.includes(:dea_licenses).where(created_at: @month.beginning_of_month..@month.end_of_month)
    CSV.generate(headers: true, write_headers: true) do |csv|
      csv << ["", "", "", "", "", "", "", "", "", "", "Previous Month", "Previous Month"]
      csv << ["Platform", "Group Name", "First Name", "Last Name", "Practitioner Type", "NPI", "DEA Number", "DEA State", "DEA Effective Date",
              "DEA Expiration Date", "DEA Expiration Date", "DEA Verification Date"]
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
          "",
          dea_licenses.pluck(:created_at).reject {|i| !i.present? }.collect { |i| i.strftime('%b %d, %Y') }.join(", ")
        ]
      end
    end
  end

  def flatforms
    @flatforms ||=  [['Credible','credible'], ['CareLogic','carelogic'], ['Insync','insync']]
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
end