class AjaxController < ApplicationController

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
    end

    head :ok
  end

  def get_group_dcos
    id = params[:group_id]
    group = EnrollmentGroup.find_by(id: id) if params[:group_id] != 'all'
    group_dco =  ( params[:group_id] != 'all' ? group.dcos.count : GroupDco.count )

    render json: {
      'group_dco' => group_dco
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

  def get_ps_provider_types
    ps_provider_types = ProviderType.all.map{|ptype| { label: ptype.fch, value: ptype.fch} }
    # render json: provider_types and return
    render json: {
      'ps_provider_types' => ps_provider_types
    }
  end

  def get_ps_selected_provider_types
    provider_source = ProviderSource.find(params[:group_id])
    selected_ps_provider_types = (provider_source.selected_ps_provider_types || [])
      render json: {
        'selected_ps_provider_types' => selected_ps_provider_types
      }
  end

  def get_states
    states = State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.alpha_code } }
    render json: {
      'states' => states
    }
  end  
  
  def get_selected_states
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_states = (provider_source.selected_states || [])
    render json: {
      'selected_states' => selected_states
    }
  end

  def get_languages
    languages = Language.all.map(&:name)
    render json: {
      'languages' => languages
    }
  end  
  
  def get_selected_languages
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_languages = (provider_source.selected_languages || [])
    render json: {
      'selected_languages' => selected_languages
    }
  end

  def get_countries
    countries = Country.all_translated.map{|country| { label: country, value: country} }
    render json: {
      'countries' => countries
    }
  end  
  
  def get_selected_countries
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_countries = (provider_source.selected_countries || [])
    render json: {
      'selected_countries' => selected_countries
    }
  end

  def get_visa_types
    visa_types = VisaType.all.map{|visa| { label: visa.name, value: visa.name} }
    render json: {
      'visa_types' => visa_types
    }
  end  
  
  def get_selected_visa_types
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_visa_types = (provider_source.selected_visa_types || [])
    render json: {
      'selected_visa_types' => selected_visa_types
    }
  end

  def get_health_plans
    health_plans = HealthPlan.all.map{|plan| { label: plan.name, value: plan.name} }
    render json: {
      'health_plans' => health_plans
    }
  end  
  
  def get_selected_health_plans
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_health_plans = (provider_source.selected_health_plans || [])
    render json: {
      'selected_health_plans' => selected_health_plans
    }
  end

  def get_hospitals
    hospitals = Hospital.all.map{|hospital| { label: hospital.name, value: hospital.name} }
    render json: {
      'hospitals' => hospitals
    }
  end  
  
  def get_selected_hospitals
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_hospitals = (provider_source.selected_hospitals || [])
    render json: {
      'selected_hospitals' => selected_hospitals
    }
  end

  def get_directories
    directories = Directory.all.map{|directory| { label: directory.name, value: directory.name} }
    render json: {
      'directories' => directories
    }
  end  
  
  def get_selected_directories
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_directories = (provider_source.selected_directories || [])
    render json: {
      'selected_directories' => selected_directories
    }
  end

  def get_specialties
    specialties = Specialty.all.map{|specialty| { label: specialty.bcbs, value: specialty.bcbs} }
    render json: {
      'specialties' => specialties
    }
  end  
  
  def get_selected_specialties
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_specialties = (provider_source.selected_specialties || [])
    render json: {
      'selected_specialties' => selected_specialties
    }
  end

  def get_training_types
    training_types = TrainingType.all.map{|training_type| { label: training_type.name, value: training_type.name} }
    render json: {
      'training_types' => training_types
    }
  end  
  
  def get_selected_training_types
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_training_types = (provider_source.selected_training_types || [])
    render json: {
      'selected_training_types' => selected_training_types
    }
  end

  def get_privilege_statuses
    privilege_statuses = PrivilegeStatus.all.map{|privilege| { label: privilege.name, value: privilege.name} }
    render json: {
      'privilege_statuses' => privilege_statuses
    }
  end  
  
  def get_selected_privilege_statuses
    provider_source = ProviderSource.find(params[:provider_source_id])
    selected_privilege_statuses = (provider_source.selected_privilege_statuses || [])
    render json: {
      'selected_privilege_statuses' => selected_privilege_statuses
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

  def delete_comment
		comment_id = params[:comment_id]&.to_i
		comment = EnrollmentComment.delete(comment_id)

		head :ok
  end
end