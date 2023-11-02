class ClientProviderEnrollmentsController < ApplicationController
	before_action :set_client_provider_enrollment, only: [:show]
  before_action :set_client_provider_enrollments, only: [:show, :index]
  def show
    @comment = @client_provider_enrollment.enrollable.comments.build(user: current_user)
  end

  def index; end

  protected

	def set_client_provider_enrollment
		@client_provider_enrollment = ClientProviderEnrollment.find(params[:id])
	end
  def set_client_provider_enrollments
    if !current_user.can_access_all_groups? && !current_user.super_administrator?
      params[:enrollment_group_ids] = current_user.enrollment_groups.pluck(:id)
    end
		@client_provider_enrollments = ClientProviderEnrollment.search_by_params(params)
    @client_providers = EnrollmentProvider.all
    @enrollment_provider_export = @client_providers
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=enrollments.xlsx"
      }
      format.html { render :index }
    end
  end
end