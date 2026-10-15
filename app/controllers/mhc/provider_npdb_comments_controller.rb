class Mhc::ProviderNpdbCommentsController < ApplicationController
	before_action :set_provider_npdb
  before_action :set_comment, only: [:destroy]

  def create
    @provider_npdb_comment = @provider_npdb.provider_npdb_comments.new(comment_params)
    @provider_npdb_comment.user = current_user

    if @provider_npdb_comment.save
      redirect_to mhc_verification_platform_path(page_tab: 'npdb', id: params[:provider_npdb_comment][:provider_npdb_id]), notice: 'Npdb comment saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record', id: params[:provider_npdb_comment][:provider_npdb_id]), alert: 'Failed to save npdb comment.'
    end
  end

  def destroy
    @provider_npdb_comment.destroy
    redirect_to mhc_verification_platform_path(page_tab: 'npdb', id: params[:provider_npdb_comment][:provider_npdb_id]), alert: 'Npdb comment deleted successfully.'
  end
  
  private
  
  def set_provider_npdb
    @provider_npdb = ProviderNpdb.find(params[:provider_npdb_comment][:provider_npdb_id])
  end
  
  def set_comment
    @provider_npdb_comment = @provider_npdb.provider_npdb_comments.find(params[:id])
  end
  
  def comment_params
    params.require(:provider_npdb_comment).permit(:subject, :message, :provider_npdb_id, :user_id)
  end
end