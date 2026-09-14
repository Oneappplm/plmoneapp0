class Mhc::ProviderPersonalInformationPeerRefsController < ApplicationController
  before_action :set_peer_ref, only: [:show, :edit, :update, :destroy]

  def index
    @peer_ref = ProviderPersonalInformationPeerRef.all
  end

  def new
    @peer_ref = ProviderPersonalInformationPeerRef.new
  end

  def create
    @peer_ref = ProviderPersonalInformationPeerRef.create(peer_ref_params)

    if @peer_ref.save
      redirect_to mhc_verification_platform_path(page_tab: 'peer_ref',id: params[:provider_personal_information_peer_ref][:provider_attest_id]), notice: 'Peer Ref detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'add_new_peer_ref',id: params[:provider_personal_information_peer_ref][:provider_attest_id]), alert: 'Failed to save Peer Ref detail.'
    end
  end

  def update
    if@peer_ref.update(peer_ref_params)
      redirect_to mhc_verification_platform_path(page_tab: 'peer_ref',id: params[:provider_personal_information_peer_ref][:provider_attest_id]), notice: 'Peer Ref detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'peer_ref_record',id: params[:provider_personal_information_peer_ref][:provider_attest_id]), alert: 'Failed to save Peer Ref detail.'
    end
  end
  
  def destroy
    provider_attest_id = @peer_ref.provider_attest_id

    if @peer_ref.destroy
      redirect_to mhc_verification_platform_path(
        page_tab: 'peer_ref',
        id: provider_attest_id
      ), notice: 'Peer Ref detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'add_new_peer_ref',
        id: provider_attest_id
      ), alert: 'Failed to delete Peer Ref detail.'
    end
  end


  private

  def set_peer_ref
    @peer_ref = ProviderPersonalInformationPeerRef.find(params[:id])
  end

  def peer_ref_params
    params.require(:provider_personal_information_peer_ref).permit(
      :provider_attest_id, :caqh_provider_attest_id,
      :title, :first_name, :middle_name, :last_name, :suffix,
      :practitioner_type, :specialty, :is_board_certified,
      :contact_method, :address, :suite_dept_mail_stop, :facility_name,
      :city, :country, :state, :county, :zip_code,
      :phone_number, :fax_number, :email_address,
      :comments, :show_on_tickler
    )
  end
end
