class Admin::ProviderProfilesController < ApplicationController
  before_action :set_provider

  def mark_verified
    @provider.update!(verification_status: "verified", failure_reason: nil)
    redirect_back fallback_location: admin_order_path(@provider.order), notice: "Marked as Verified"
  end

  def mark_failed
    @provider.update!(verification_status: "failed", failure_reason: params[:reason])
    redirect_back fallback_location: admin_order_path(@provider.order), alert: "Marked as Failed"
  end

  private

  def set_provider
    @provider = ProviderProfile.find(params[:id])
  end
end
