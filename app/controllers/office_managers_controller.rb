class OfficeManagersController < ApplicationController
  before_action :set_provider, only: [:manage_applications, :send_invite, :remove_provider]
  before_action :set_current_provider, only: [:credentialing_application, :view_summary, :re_attest_application]
  before_action :set_client_organizations, only: [:show]

  def index
    clean_empty_providers

    if params[:practice_location_id].blank? || params[:practice_location_id] == 'All Location'
      # Display all providers if no practice_location_id is provided or if "All Location" is selected
      @providers = ProviderSource.unscoped.order(created_at: :asc).paginate(page: params[:page], per_page: 12)
    else
      # Display providers filtered by practice_location_id
      @providers = ProviderSource.unscoped
                                 .where(practice_location_id: params[:practice_location_id])
                                 .order(created_at: :asc)
                                 .paginate(page: params[:page], per_page: 12)
    end
  end



 def manage_practice_locations
  @locations = if params[:search].present?
   PracticeLocation.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
 else
   PracticeLocation.paginate(per_page: 10, page: params[:page] || 1)
 end

 @non_associated_providers = ProviderSource.where(practice_location_id: nil)
 @providers = ProviderSource.unscoped.where(practice_location_id: params[:practice_location_id])
 .order(created_at: :asc)
 .paginate(page: params[:page], per_page: 12)

 response_data = {
  non_associated_providers: @non_associated_providers.map { |provider| { id: provider.id, full_name: provider.full_name } },
  providers: @providers.map { |provider| { id: provider.id, full_name: provider.full_name } }
}

respond_to do |format|
  format.html { render 'manage_practice' }
      format.json { render json: response_data } # Removed unnecessary extra hash
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

  def update_provider_associations
    practice_location_id = params[:practice_location_id]

    associated_providers = params[:associated_providers].present? ? JSON.parse(params[:associated_providers]) : []
    disassociated_providers = params[:disassociated_providers].present? ? JSON.parse(params[:disassociated_providers]) : []

    # Update associated providers only if there are any
    if associated_providers.any?
      ProviderSource.where(id: associated_providers).update_all(practice_location_id: practice_location_id)
    end

    # Remove practice location from disassociated providers only if there are any
    if disassociated_providers.any?
      ProviderSource.where(id: disassociated_providers).update_all(practice_location_id: nil)
    end

    render json: { status: "success" }
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
    results = [] # Collect results

    if mode == 'single-invite'
      results << send_email_to_provider(params[:id])
    elsif mode == 'bulk-invites'
      provider_ids = params[:id].split(',')
      provider_ids.each do |provider_id|
        results << send_email_to_provider(provider_id)
      end
    end

    flash[:notice] = 'Invitation sent successfully.'
    
    # Only render ONCE
    render json: { status: 'success', results: results }
  end

  def send_email_to_provider(provider_id)
    api_service = ProviderSource::SendInviteService.call(
      ProviderSource.find_by(id: provider_id),
      params
      )

    if api_service.success?
      api_service.display_result
    else
      { error: api_service.display_error, status: 500 }
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
