class EnrollmentClientsController < ApplicationController
  before_action :set_providers, only: [:index, :download_documents, :show, :reports, :notifications, :dashboard]
  before_action :set_provider, only: [:show]
  before_action :set_incomplete_providers, only: [:show, :index, :reports, :notifications, :dashboard]
  def index; end

  def show
    if params[:mode].present?
      render params[:mode]
    end
  end

  def reports;end

  def notifications


    @provider = if params[:provider_id]
      Provider.find(params[:provider_id])
    else
      @incomplete_providers.first
    end

    if @provider
      @show_missing_fields = @provider.show_missing_fields?
      @provider.build_licenses if @provider.licenses.nil?
    end
  end

  def providers_to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Provider Status", "Client", "Location", "First Name", "Middle Name", "Last Name", "Practitioner Type", "NPI", "Practitioner SSN"]

      @providers.each do |provider|
        csv << [
          "",
          provider&.client&.group_name,
          provider&.location&.dco_name,
          provider&.first_name,
          provider&.middle_name,
          provider&.last_name,
          provider&.practitioner,
          provider&.npi,
          provider&.ssn
        ]
      end
    end
  end

  def download_documents
    respond_to do |format|
      format.csv { send_data providers_to_csv, filename: "Providers.csv" }
    end
  end

  def dashboard
    @providers_with_missing_details ||= Provider.with_missing_required_fields.count
    @providers_with_missing_documents ||= Provider.with_missing_required_docs.count
  end

  def groups
    @enrollment_groups = EnrollmentGroup.all
  end

  def view_group
    @states = State.all
    @view_only = true
		@enrollment_group = EnrollmentGroup.find params[:group_id]

		if @enrollment_group.contact_personnels.blank?
			@enrollment_group.contact_personnels.build
		end

		if @enrollment_group.details.blank?
			@enrollment_group.details.build
		end

		@enrollment_group.qualifacts_contacts.build if current_setting.qualifacts? && !@enrollment_group.qualifacts_contacts.present?

		render 'enrollments/new_group'
  end

  protected

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def set_providers
   @providers = Provider.joins(:group).order('enrollment_groups.group_name, providers.id')
    @providers = @providers.search_by_params(params)

    # render json: params and return


    # this will need refactoring just went with this for now for hotfix
    if !params[:enrollment_status].blank?
    # render json: params and return
      status_ids = EnrollmentProvidersDetail.where(enrollment_status: params[:enrollment_status]).pluck(:enrollment_provider_id)
      provider_ids = @providers.joins(enrollments: :details)
                                       .where(enrollment_providers: { id: status_ids }).pluck(:id)
      @providers = Provider.where(id: provider_ids)
    end

    @providers = @providers.paginate(per_page: 50, page: params[:page] || 1)
    # @providers = Provider.search_by_params(params).paginate(per_page: 50, page: params[:page] || 1)

  end

  def set_incomplete_providers
    @incomplete_providers ||= Provider.search_by_params(params).with_missing_required_attributes.paginate(per_page: 50, page: params[:page] || 1)
  end

end