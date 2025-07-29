class Mhc::ProviderPersonalInformationCommentsController < ApplicationController
	before_action :set_provider_personal_information, only: [:create]

  def create
    @provider_personal_information_comment = @provider_personal_information.provider_personal_information_comments.new(comment_params.except(:page_tab))
    @provider_personal_information_comment.user = current_user

    if @provider_personal_information_comment.save
      redirect_to request.referer, notice: 'comment saved successfully.'
    else
      redirect_to request.referer, alert: 'Failed to save comment.'
      redirect_to mhc_verification_platform_path(page_tab: comment_params[:page_tab], id: @provider_personal_information.provider_attest_id), alert: 'Failed to save comment.'
    end
  end

  def destroy
    @provider_personal_information_comment = ProviderPersonalInformationComment.find(params[:id])
    provider_attest_id = @provider_personal_information_comment.provider_personal_information.provider_attest_id

    if @provider_personal_information_comment.destroy
       redirect_to request.referer, notice: 'comment saved successfully.'
    else
      redirect_to request.referer, alert:  'Failed to delete the comment.'
    end
  end

  private

  def set_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find(comment_params[:provider_personal_information_id])
  end

  def comment_params
    params.require(:provider_personal_information_comment).permit(:subject, :message, :provider_personal_information_id, :page_tab)
  end
end
