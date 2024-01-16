class AjaxController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:logout_on_close]

  def delete_record
    # render json: params and return
    id = params[:id]
    model = params[:model]
    if model == 'licenses'
      ProviderLicense.delete(id)
    elsif model == 'taxonomies'
      ProviderTaxonomy.delete(id)
    elsif model == 'np_licenses'
      ProviderNpLicense.delete(id)
    elsif model == 'rn_licenses'
      ProviderRnLicense.delete(id)
    elsif model == 'group_dco_schedules'
      GroupDcoSchedule.delete(id)
    elsif model == 'qualifacts_contacts'
      GroupContact.delete(id)
    elsif model == 'group_dco_provider_outreach_info'
      GroupDcoProviderOutreachInformation.delete(id)
    elsif model == 'dea_licenses'
      ProviderDeaLicense.delete(id)
    elsif model == 'cnp_licenses'
      ProviderCnpLicense.delete(id)
    elsif model == 'ins_policies'
      ProviderInsPolicy.delete(id)
    elsif model == 'group_dco_notes'
      GroupDcoNote.delete(id)
    elsif model == 'provider_notes'
      ProviderNote.delete(id)
    elsif model == 'comment'
      EnrollmentComment.delete(id)
    elsif model == 'payer_questions'
      ProvidersPayerLoginsQuestion.delete(id);
    end

    head :ok
  end

  def create_group_dco_note
    @group_dco_note = GroupDcoNote.create(group_dco_notes_params)
    render json: { html: render_to_string(partial: 'dcos/qualifacts/group_dco_note', locals: { group_dco_note: @group_dco_note }).html_safe }
  end

  def create_provider_note
    @provider_note = ProviderNote.create(provider_notes_params)
    PlmMailer.with(
      email: Setting.take.t('system_notification_email'),
      subject: "Added Note to Provider Profile",
      body: "#{current_user&.full_name} added a new note to provider: #{@provider_note&.provider&.provider_name}"
    ).send_system_notification.deliver_later
    render json: { html: render_to_string(partial: 'providers/provider_note', locals: { provider_note: @provider_note }).html_safe }
  end

  def create_roles
    @role = Role.create(roles_params)
    render json: {
      'name' => @role.name,
      'slug' => @role.slug
    }
  end

  def create_enrollment_comment
    @comment = EnrollmentComment.create(comment_params)
    render json: { html: render_to_string(partial: 'comments/comment', locals: { comment: @comment }).html_safe }
  end

  def get_group_dcos
    id = params[:group_id]
    group = EnrollmentGroup.find_by(id: id) if params[:group_id] != 'all'
    group_dcos = ( params[:group_id] != 'all' ? group.dcos : GroupDco )
    providers = ( params[:group_id] != 'all' ? group.providers : Provider )
    if current_user.can_access_all_groups? || current_user&.super_administrator?
      group_dco_count =  group_dcos.count
      provider_count = providers.count
    else
      group_dco_count =  group_dcos.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).count
      provider_count = providers.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).count
    end
    render json: {
      'group_dco_count' => group_dco_count,
      'provider_count' => provider_count,
      'group_dco_dropdown' => { html: render_to_string(partial: "providers/overview_components/group_dco_dropdown", locals: { group_dcos: group_dcos }).html_safe }
    }
  end

  def get_provider_payers
    payer = params[:enrollment_payer]
    # provider = EnrollmentProvider.find_by(id: id)
    # render json: provider.details and return
    # render json: params and return

    render json: {
      'submitted' => EnrollmentProvidersDetail.send(payer).submitted.count + EnrollGroupsDetail.send(payer).submitted.count,
      'processing' => EnrollmentProvidersDetail.send(payer).processing.count  + EnrollGroupsDetail.send(payer).processing.count,
      'approved' =>  EnrollmentProvidersDetail.send(payer).approved.count  + EnrollGroupsDetail.send(payer).approved.count,
      'denied' => EnrollmentProvidersDetail.send(payer).denied.count  + EnrollGroupsDetail.send(payer).denied.count,
      'terminated' => EnrollmentProvidersDetail.send(payer).terminated.count + EnrollGroupsDetail.send(payer).terminated.count,
      'not_eligible' =>  EnrollmentProvidersDetail.send(payer).not_eligible.count + EnrollGroupsDetail.send(payer).not_eligible.count
    }


  end

  def get_enrollment_status_count
    model = params[:model]
    status = params[:status]
    count = if model == 'enrollment_providers'
      EnrollmentProvider.send(status).count
    elsif model == 'enroll_groups'
      EnrollGroup.send(status).count
    else
      0
    end
    render json: {
      'count' => count
    }
  end

  def change_enrollment_status
    id = params[:id]
    model = params[:model]
    status = params[:status]
    enrollment_type = if model == 'enrollment_providers'
        EnrollmentProvider.find_by(id: id)
      elsif model == 'enroll_groups'
        EnrollGroup.find_by(id: id)
    end

    enrollment_type.update_attribute('status', status) if enrollment_type

    render json: {
      'status' => enrollment_type&.status&.titleize,
      'id' => enrollment_type.id
    }
  end

  def get_provider_types
    provider_types = ProviderType.all.map{|m| { label: m.fch, value: m.fch} }
    # render json: provider_types and return
    render json: {
      'provider_types' => provider_types
    }
  end

  def get_enrollment_group_locations
    enrollment_group = EnrollmentGroup.find_by(id: params[:group_id])
    dcos = enrollment_group.present? ? enrollment_group.dcos.where(location_status: 'active').map { |m| { label: m.dco_name, value: m.id } } : []
    render json: {
      "practice_locations" => dcos
    }
  end

  def get_provider_notification_services
    notification_services = if current_setting.dcs?
      dcs_notification_services
    else
      provider_notification_services
    end
    render json: {
      'notification_services' => notification_services.map { |m| { label: m[0], value: m[1]} }
    }
  end

  def get_group_notification_services
    notification_services = if current_setting.dcs?
      dcs_notification_services
    else
      group_notification_services
    end
    render json: {
      'notification_services' => notification_services.map { |m| { label: m[0], value: m[1]} }
    }
  end

  def get_enrollment_groups
    if current_user&.can_access_all_groups || current_user&.super_administrator?
      enrollment_groups = EnrollmentGroup.all.map { |m| { label: m.group_name, value: m.id} }
    else
      enrollment_groups = current_user.enrollment_groups.map { |m| { label: m.group_name, value: m.id} }
    end
    render json: {
      'enrollment_groups' => enrollment_groups
    }
  end

  def get_selected_provider_types
    enrollment_group = EnrollmentGroup.find(params[:group_id])
    selected_provider_types = (enrollment_group.selected_provider_types || [])
      render json: {
        'selected_provider_types' => selected_provider_types
      }
  end

  def get_selected_practitioner_types
    provider_practitioner_type = Provider.find(params[:provider_id])
    selected_practitioner_types = (provider_practitioner_type.selected_practitioner_types || [])
    render json: {
      'selected_practitioner_types' => selected_practitioner_types
    }
  end

  def get_providers
    providers = Provider.all.map { |provider| { label: provider.provider_name, value: provider.id } }
    render json: {
      'providers' => providers
    }
  end

  def get_provider
    @provider = Provider.find(params[:id] || params[:provider_id])
    @comment = @provider.comments.build(user: current_user)
    render json: { html: render_to_string(partial: 'providers/show', locals: { provider: @provider }).html_safe }
  end

  def get_client_provider_enrollment
		@client_provider_enrollment = ClientProviderEnrollment.find(params[:id])
    @comment = @client_provider_enrollment.enrollable.comments.build(user: current_user)
    render json: { html: render_to_string(partial: 'client_provider_enrollments/show', locals: { client_provider_enrollment: @client_provider_enrollment, comment: @comment }).html_safe }
	end

  def new_edit_practice_location
    @practice_location = params[:id].present? ? PracticeLocation.find(params[:id]) : PracticeLocation.new
    render json: { html: render_to_string(partial: 'office_managers/practice_location_modal', locals: { practice_location: @practice_location }).html_safe }
  end

  def get_selected_providers
    enrollment_provider = EnrollmentProvider.find(params[:enrollment_provider_id])
    selected_providers = (enrollment_provider.selected_providers || [])
      render json: {
        'selected_providers' => selected_providers
      }
  end

  def get_dougnut_data
    clients = [Client.attested.count,Client.no_application.count,
                Client.complete.count,Client.incomplete.count,
                Client.pending_data.count, Client.in_process.count,
                Client.psv.count, Client.returned.count
            ]
    total_clients = clients.sum
    percentages = clients.map{|c| ((c.to_f/total_clients.to_f)*100).round(2)}

    render json: {
      "clients" => clients,
      "percentages" => percentages
    }
  end

  def get_dashboard_providers
    range = params[:range]
    providers = EnrollmentProvider.send(range)
    enrolled_providers = [ providers.count, providers.assigned.count,
                           providers.completed.count, providers.terminated.count,
                           providers.unassigned.count
                         ]
    render json: {
      "providers" => enrolled_providers
    }
  end

  def update_collapse
    collapse_name = params[:collapse_name]
    if UserSidebarPreference.exists?(user_id: current_user&.id, collapse_name: collapse_name)
      collapse = UserSidebarPreference.find_by(user_id: current_user&.id, collapse_name: collapse_name)
      collapse.update_attribute('is_open', !collapse.is_open)
    else
      UserSidebarPreference.create(user_id: current_user&.id, collapse_name: collapse_name, is_open: false)
    end
    head :ok
  end

  def get_monthly_visits
     months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
     current_month = Time.now.strftime('%B')
     month_range = months_before = months.slice(0, months.index(current_month) + 1)
      # for now only available is hvhs
     visit_data = []
     month_range.each_with_index do |m,idx|
      visit_data << Visit.hvhs_count(idx+1)
     end

     render json: {
      'visits' => visit_data
     }
  end

  def browser_visits
    browser_data = [Visit.chrome_count, Visit.safari_count, Visit.firefox_count]

    render json: {
      'browser_data' => browser_data
    }
  end

  def state_providers
    providers ||= State.providers_count

    state_data = providers.map { |state| [state.name, state.providers_count, state.color, state.alpha_code] }


    render json: {
      'state_providers' => state_data
    }

  end

  def providers_gender
    genders = [Provider.male.count, Provider.female.count, Provider.non_binary.count]

    render json: {
      'genders' => genders
    }
  end

  def get_specialties
    specialties = Specialty.all.map{|m| { label: m.bcbs, value: m.bcbs} }
    # render json: provider_types and return
    render json: {
      'specialties' => specialties
    }
  end

  def get_languages
    languages = Language.all.map{|m| { label: m.name, value: m.name} }
    # render json: provider_types and return
    render json: {
      'languages' => languages
    }
  end

  def get_states
    states = State.all.map{|m| { label: "#{m.name} - #{m.alpha_code}", value: m.name} }
    render json: {
      'states' => states
    }
  end

  def get_states_with_id
    states = State.all.map{|m| { label: "#{m.name} - #{m.alpha_code}", value: m.id} }
    render json: {
      'states' => states
    }
  end

  def get_provider_practitioner_types
    provider_id = params[:provider_id]
    provider = Provider.find(provider_id)
    practitioner_types = provider.practitioner_type.split(',')

    render json: {
      'practitioner_types' => practitioner_types
    }
  end

  def get_provider_specialties
    provider_id = params[:provider_id]
    provider = Provider.find(provider_id)
    specialties = provider.specialty.split(',')

    render json: {
      'specialties' => specialties
    }
  end

  def get_group_roles
    group_roles = GroupRole.all.map{|m| { label: m.name, value: m.name} }
    render json: {
      'group_roles' => group_roles
    }
  end   

  def update_timeline
    timeline_id = params[:timeline_id]
    timeline = ProvidersTimeLine.find(timeline_id)
    timeline.update_attribute('status','done')
    head :ok
  end

  def mark_notification_read
    notification = Notification.find(params[:notification_id])
    notification.mark_as_read!
    head :ok
  end

  def logout_on_close
    if current_user.present?
      logout_on_close = params[:logout_on_close] || true
      current_user.update_attribute('logout_on_close', logout_on_close)
      if logout_on_close
        current_user.update_attribute('last_logout_on_close', Time.now)
      else
        current_user.update_attribute('last_logout_on_close', nil)
      end
    end
  end

  def create_payor_name
    @payor_name = PayorName.new(title: params[:payor_name][:title])

    if @payor_name.save
      head :ok
    else
      render json:  { message: @payor_name.errors}, status: :unprocessable_entity
    end
  end

  protected

  def provider_notification_services
    [
			['Practice/Provider Setup', 'provider_setup'],
			['Monthly Monitoring', 'monthly_monitoring'],
			['Facility Enrollment', 'facility_enrollment'],
			['Provider Enrollment', 'provider_enrollment'],
      ['Enrollment Required Maintenance', 'enrollment_maintenance'],
			['FBI Checks', 'fbi_checks'],
			['Hospital Org PSV', 'hospital_org'],
      ['Facility Re-Enrollment', 'facility_enrollment'],
      ['Provider Re-Enrollment', 'provider_enrollment']
		]
  end

  def dcs_notification_services
    [
      ['Credentialing', 'credentialing'],
      ['Add Location', 'add_location'],
      ['Re-credentialing', 're_credentialing'],
      ['Gold Subscription', 'gold_subscription'],
      ['Silver Subscription', 'silver_subscription'],
      ['Bronze Subscription', 'bronze_subscription']
    ]
  end

  def group_notification_services
    [
      ['Practice/Provider Setup', 'provider_setup'],
			['Monthly Monitoring', 'monthly_monitoring'],
			['Facility Enrollment', 'facility_enrollment'],
			['Provider Enrollment', 'provider_enrollment'],
      ['Enrollment Required Maintenance', 'enrollment_maintenance'],
			['FBI Checks', 'fbi_checks'],
			['Hospital Org PSV', 'hospital_org']
		]
  end

  def group_dco_notes_params
    params.require(:data).permit(
      :title, :description, :group_dco_id
    )
  end

  def provider_notes_params
    params.require(:data).permit(
      :title, :description, :provider_id
    )
  end

  def roles_params
    params.require(:data).permit(
      :name
    )
  end
  def comment_params
    params.require(:data).permit(
      :enrollment_provider_id, :enroll_group_id,
      :provider_id, :user_id, :body
    )
  end
end