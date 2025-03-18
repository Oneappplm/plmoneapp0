class AuditTrailsController < ApplicationController
	before_action :find_auditable, only: [:show]
	def index
    if params[:tab].blank? || params[:tab] == "user"
		  @audit_trails	= CustomAudit.where(auditable_type: ['Provider', 'EnrollmentProvidersDetail', 'User'])
    elsif params[:tab] == "admin"
      @security_logs = SecurityLog.where(trackable_type: "Admin").order(created_at: :desc)
    end
	end

	def show
		@audit_trails = @auditable.audits

		respond_to do |format|
			format.html
			format.json { render json: @audit_trails }
		end
	end

	protected
	def find_auditable
		id = params.dig(:id)
		type = params.dig(:type)

		@auditable = type.titleize.constantize.find_by_id(id) rescue nil
	end
end
