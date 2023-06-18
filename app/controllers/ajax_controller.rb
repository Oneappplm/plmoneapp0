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
    id = params[:provider_id]
    provider = EnrollmentProvider.find_by(id: id)
    # render json: provider.details and return
    # render json: params and return

    render json: {
      'submitted' => provider.details.submitted.count,
      'processing' => provider.details.processing.count,
      'approved' =>  provider.details.approved.count,
      'denied' => provider.details.denied.count,
      'terminated' => provider.details.terminated.count
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

  def get_dougnut_data
    clients = [Client.attested.count,Client.no_application.count,
                Client.complete.count,Client.incomplete.count,
                Client.pending_data.count, Client.in_process.count,
                Client.psv.count, Client.returned.count
            ]
    total_clients = clients.sum
    percentages = clients.map{|c| ((c.to_f/total_clients.to_f)*100).to_i}
    
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
end