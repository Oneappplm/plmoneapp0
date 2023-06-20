class OfficeManagersController < ApplicationController
  before_action :set_provider, only: [:manage_applications, :send_invite, :remove_provider]
  before_action :set_current_provider, only: [:credentialing_application, :view_summary, :re_attest_application]
  def index
    if params[:template].present?
      render params[:template]
    else
      clean_empty_providers
      @providers = ProviderSource.unscoped.order(created_at: :asc).paginate(page: params[:page], per_page: 10)
    end
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
		redirect_to custom_provider_source_path
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
    provider = ProviderSource.find(params[:id])

    if provider.email_address.blank?
      flash[:alert] = 'Email is required.'
    else
      User.invite!(email: provider.email_address, user_role: 'office_manager')
      provider.increment!(:invitation_count)
      provider.update(invitation_sent_at: Time.now)
      flash[:notice] = 'Invitation sent successfully.'
    end
  end

  protected
  def set_provider
    @provider = ProviderSource.find(params[:id])
  end

  def set_current_provider
    current_provider_source.update(current_provider_source: false)
		ProviderSource.find(params[:id]).update(current_provider_source: true)
  end
end
