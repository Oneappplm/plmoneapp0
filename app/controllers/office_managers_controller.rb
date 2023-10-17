class OfficeManagersController < ApplicationController
  before_action :set_provider, only: [:manage_applications, :send_invite, :remove_provider]
  before_action :set_current_provider, only: [:credentialing_application, :view_summary, :re_attest_application]
  before_action :set_client_organizations, only: [:show]
  def index
    if params[:template].present?
      if params[:template] == 'manage_practice'
        @locations = if params[:search].present?
          PracticeLocation.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
        else
          PracticeLocation.paginate(per_page: 10, page: params[:page] || 1)
        end
      end
      render params[:template]
    else
      clean_empty_providers
      if params[:practice_location_id].present? && params[:practice_location_id] == 'All Location'
        redirect_to office_managers_path
      end

      @providers = ProviderSource.unscoped.where(practice_location_id:  params[:practice_location_id]).order(created_at: :asc).paginate(page: params[:page], per_page: 12)
    end
  end

  def show
    @client_organizations = ClientOrganization.all
    @client_organization = ClientOrganization.find(params[:id])
  end

  def clean_empty_providers
    ProviderSource.unscoped.each do |provider|
      if !provider.full_name.present?
        provider.destroy
      end
    end
  end

  def manage_applications; end

  def credentialing_application
		redirect_to edit_provider_source_path(id: params[:id])
  end

  def view_summary
    redirect_to view_summary_index_path
  end

  def re_attest_application
    redirect_to custom_provider_source_path(page: 'reattest_application')
  end

  def remove_provider
    @provider.destroy
		redirect_to request.referrer, notice: "Provider Source is deleted."
  end

  def bulk_remove_providers
    data = params[:data]
    providers = ProviderSource.where(id: data)
    providers.destroy_all
    flash[:notice] = "Selected Providers are successfully deleted."

    render json: {
      status: 'success',
    }
  end

  def send_invitation
    User.invite!(email: params[:emailTo], user_role: 'office_manager')
    render json: {
      status: 'success',
    }
  end

  def send_invite
    mode = params[:mode]
    if mode == 'single-invite'
      send_email_to_provider params[:id]
    elsif mode == 'bulk-invites'
      providerids = params[:id].split(',')
      providerids.each do |provider_id|
        send_email_to_provider provider_id
      end
    end
    flash[:notice] = 'Invitation sent successfully.'
  end

  def send_email_to_provider provider_id
    api_service = ProviderSource::SendInviteService.call(
      ProviderSource.find_by(id: provider_id),
      params
    )

    if api_service.success?
      render json: api_service.display_result
    else
      render json: api_service.display_error, status: 500
    end
  end

  protected
  def set_client_organizations
    @client_organization = ClientOrganization.find(params[:id])
  end

  def set_provider
    @provider = ProviderSource.find(params[:id])
  end

  def set_current_provider
    ProviderSource.update_all(current_provider_source: false)
		ProviderSource.find(params[:id]).update(current_provider_source: true)
  end
end
