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

  def active_providers_report
    @month = params[:month].present? ? DateTime.parse(params[:month].split("-").join("/")) : nil
    providers = Provider.where(created_at: @month.beginning_of_month..@month.end_of_month).where(status: 'active')
    
    CSV.generate(headers: true) do |csv|
      csv << ["First Name", "Middle Name", "Last Name", "Status", "Date Profile Created in One App"]
      providers.each do |provider|
        csv << [
          provider.first_name,
          provider.middle_name,
          provider.last_name,
          provider.status,
          provider.created_at&.strftime('%b %d, %Y')
        ]
      end
    end
  end

  def download_documents
    @month = params[:month].present? ? DateTime.parse(params[:month].split("-").join("/")) : nil

    if params[:template] == 'active_providers_report'
      csv_content = active_providers_report

      file_name = "active_providers_report_#{params[:month]}.csv"
      send_data csv_content, filename: file_name, type: 'text/csv'
    else
      eval("#{params[:template]}_to_csv")

      file_name = "#{params[:template]}_to_csv"
      file_name = "#{file_name}_#{params[:month]}" if params[:month].present?
      render xlsx: file_name, template: "enrollment_clients/report_templates/#{current_setting.client_name}/#{params[:template]}_to_csv"
    end
  end

  def download_agent_report
    agent_id = params[:template]
    @month = params[:month].present? ? DateTime.parse(params[:month].split("-").join("/")) : nil

    selected_start_date = nil
    selected_end_date = nil

    if params[:daterange].present?
      start_date, end_date = params[:daterange].split(' - ')

      # Parse start and end dates from the date range string
      selected_start_date = DateTime.parse(start_date)
      selected_end_date = DateTime.parse(end_date)
    end

    respond_to do |format|
      format.xlsx do
        agent_report = agent_report_to_xlsx(agent_id, selected_start_date, selected_end_date)
        send_data agent_report, filename: "agent_report_#{agent_id}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.xlsx"
      end
    end
  end

  def agent_report_to_xlsx(agent_id, start_date, end_date)
    agent = User.find(agent_id)

    # Parse start and end dates if they are not already in DateTime format
    if start_date.present? && end_date.present?
      start_date = DateTime.parse(start_date) unless start_date.is_a?(DateTime)
      end_date = DateTime.parse(end_date) unless end_date.is_a?(DateTime)
    end

    # Filter audit logs by the selected date range
    audit_logs = if start_date && end_date
      agent.audits.where(action: 'update', created_at: start_date.beginning_of_day..end_date.end_of_day).order(created_at: :desc)
    else
      agent.audits.where(action: 'update').order(created_at: :desc)
    end

    # Generate XLSX using Axlsx gem
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Agent Report") do |sheet|
      sheet.add_row ["Agent Email", "Action", "Time", "Report Generation Date"]

      audit_logs.each do |log|
        action = log.audited_changes["logout_on_close"] ? "Logged out on close" : "Logged in"
        sheet.add_row [
          agent.email,
          action,
          log.created_at.strftime('%b %d, %Y %H:%M:%S'),
          Time.now.strftime('%b %d, %Y %H:%M:%S')
        ]
      end
    end

    package.to_stream.read
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
    @enrollment_details = EnrollmentProvidersDetail.includes(enrollment_provider: [provider: :group])
                              .where(enrollment_status: 'application-submitted')
                              .where(start_date: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def group_submitted_enrollments_to_csv
    @enrollment_details = EnrollGroupsDetail.includes(:application_status_logs, enroll_group: :group).where(application_status: 'application-submitted').where(application_status_logs: { created_at: @month.beginning_of_month..@month.end_of_month })
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def license_report_to_csv
    @providers = Provider.includes(:licenses, :cnp_licenses, :rn_licenses, :group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def dea_to_csv
    @providers = Provider.includes(:dea_licenses, :group)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
    if @month.present?
      @providers = @providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
  end

  def caqh_to_csv
    @providers = Provider.includes(:group)
    if @month.present?
      @providers = @providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end
  def oig_to_csv
    @providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end
  def sam_to_csv
    @providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def missing_items_report_to_csv
    @providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def liability_to_csv
    @providers = Provider.includes(:group)
    if @month.present?
      @providers = @providers.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def provider_enrollment_details_report_to_csv
    @enrollment_details = EnrollmentProvidersDetail.includes(:application_status_logs, enrollment_provider: [provider: :group])
    if @month.present?
      @enrollment_details = @enrollment_details.where(created_at: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = @enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def provider_revalidation_report_to_csv
    @enrollment_details = EnrollmentProvidersDetail.includes(enrollment_provider: [provider: :group])
                              .where(enrollment_status: 'approved')
    if @month.present?
      @enrollment_details = @enrollment_details.where(enrollment_effective_date: @month.beginning_of_month..@month.end_of_month)
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def group_detail_report_to_csv
    @enrollment_details = EnrollGroupsDetail.includes(enroll_group: :group)
    if @month.present?
      @enrollment_details = @enrollment_details.where(enroll_groups: { created_at: @month.beginning_of_month..@month.end_of_month })
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = @enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
    end
  end

  def group_revalidation_to_csv
    @enrollment_details = EnrollGroupsDetail.includes(enroll_group: :group).where("enroll_groups_details.application_status = ?", 'approved')
    if @month.present?
      @enrollment_details = @enrollment_details.where(enroll_group: { created_at: @month.beginning_of_month..@month.end_of_month })
    end
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @enrollment_details = @enrollment_details.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
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

    @providers = Provider.find_by_sql(sql)
  end

  def new_profile_setup_in_one_app_to_csv
    @providers = Provider.includes(:group).where(created_at: @month.beginning_of_month..@month.end_of_month)
    if current_user.clinic_admin? || current_user.clinic_super_admin?
      @providers = @providers.where.not(group: {id: nil}).where(group: { group_name: current_user&.enrollment_groups&.pluck(:group_name)})
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

  def csv_filename
    if @month.present?
      "#{params[:template]&.dasherize}-#{@month.strftime("%Y-%m")}.csv"
    else
      "#{params[:template]&.dasherize}-all.csv"
    end
  end
end
