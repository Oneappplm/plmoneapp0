class PagesController < ApplicationController
  include Sys
	before_action :set_global_search, only: [:virtual_review_committee]
	before_action :set_clients, only: %i[client_portal show_client_details data_access]
	before_action :search_clients, only: %i[client_search data_access]
	before_action :search_inputs, only: %i[client_search client_portal data_access]
	before_action :get_states, only: %i[client_search client_portal virtual_review_committee provider_source all_clients new_dco new_group data_access]
	before_action :get_provider_types, only: %i[client_search client_portal virtual_review_committee provider_source provider_enrollment new_group data_access]
	before_action :get_specialties, only: %i[client_search client_portal virtual_review_committee provider_source provider_enrollment data_access]
	before_action :get_languages, only: %i[provider_source data_access]
	before_action :get_health_plans, only: %i[provider_source data_access]
	before_action :get_disclosures, only: %i[provider_source]
	before_action :get_practice_types, only: %i[provider_source]
	before_action :get_practitioner_profiles, only: %i[provider_source]
	before_action :get_services, only: %i[provider_source]
	before_action :get_education_types, only: %i[provider_source]
	before_action :set_provider
  before_action :has_incomplete_tabs, only: [:provider_source]
	before_action :redirect_to_default_page, only: [:dashboard]

	layout "public_application", only: %i[terms privacy_policy data_access]
	layout "overview", only: %i[dashboard]

  # Will be used to convert bytes to gb
  GB_DISIVOR = 1_073_741_824
  MB_DIVISOR = 1_048_576

	def provider_source
		@provider_sources = ProviderSource.all
		@provider = current_user.provider_source_lookup
    build_initial_associations
		HtmlUtils.set_current_provider_source(@provider)

    if params[:add_new].present?
      new_association(params[:add_new])
    end

    if params[:remove_record].present?
      delete_association_record(params[:remove_record], params[:id])
    end

		if params[:page].present?
			render "pages/provider_source/#{params[:page]}", layout: 'provider_source'
		else
			render layout: 'provider_source'
		end
	end

	def dashboard
			stat = Sys::Filesystem.stat('/')
			total_size_bytes = stat.blocks * stat.block_size
			free_size_bytes = stat.blocks_available * stat.block_size
			used_size_bytes = total_size_bytes - free_size_bytes

			@total_size_gb = total_size_bytes/GB_DISIVOR
			@free_size_gb = free_size_bytes/GB_DISIVOR
			@used_size_gb = used_size_bytes/GB_DISIVOR
			@used_size_mb = used_size_bytes/MB_DIVISOR
			@used_size_percent = ((used_size_bytes.to_f/total_size_bytes.to_f) * 100).to_i
			@free_size_percent = ((free_size_bytes.to_f/total_size_bytes.to_f) * 100).to_i
			@state_providers = State.providers_count
	end

	def plm_sales_tool
		render layout: 'plm_sales_tool'
	end

	def virtual_review_committee
		@vrcs = if @global_search_text.present?
			VirtualReviewCommittee.search(@global_search_text)
		else
			VirtualReviewCommittee.all
		end

		if params[:'vrc-progress-status'].present? && params[:'vrc-progress-status'] != 'all'
			@vrcs = @vrcs.send(params[:'vrc-progress-status'])
		end

		@vrcs = @vrcs.paginate(page: params[:page], per_page: 50)

		if params[:vrc].present? && params[:vrc] == 'work-tickler'
			render 'work_tickler'
		elsif params[:vrc].present? && params[:vrc] == 'documents'
			render 'documents'
		elsif params[:vrc].present? && params[:vrc] == 'reports'
			render 'reports'
		elsif params[:vrc].present? && params[:vrc] == 'issue'
			render 'issue'
		end
	end


	def client_portal
		@simple_search = (params[:none].present? && params[:none]['simple_search'])
		@grid = (params[:grid].present? or (params[:none].present? &&params[:none]['grid'].present?))
	end

	def show_client_details
		@client = Client.find(params[:client_id])
	end

  def client_search
  	@status = params[:cred_status] || nil
    @clients = if @global_search_text.present?
			Client.search(@global_search_text)
		else
			Client.all
		end

		if !params[:from_attest_date].blank? && !
			params[:to_attest_date].blank?
			from_date = params[:from_attest_date].to_date
			to_date = params[:to_attest_date].to_date
			@clients =  @clients.where('attested_date BETWEEN ? AND ?', from_date, to_date)
		end

		if !params[:birth_date].blank?
			bday = params[:birth_date].to_date
			@clients = @clients.where('EXTRACT(month FROM birth_date) = ? AND EXTRACT(day FROM birth_date) = ?', bday.month, bday.day).order("created_at DESC")
		end
		if !params[:medv_ids].blank?
			ids = params[:medv_ids].split(',').map{|m| m.downcase.gsub('"','').strip}
			@clients = @clients.where("lower(medv_id) IN (?)", ids)
			# render json: ids and return
		end
		@clients = @clients.paginate(per_page: 100, page: params[:page] || 1)
		render "client_portal"
  end

  def download_clients
  	@clients = Client.where.not(id: nil)
  	respond_to do |format|
  		format.csv { send_data @clients.to_csv, filename: "Clients-#{Time.now.to_date}.csv" }
  	end
  end

  def show_virtual_review_committee
  	if params[:client_id].present?
  		@vrc = VirtualReviewCommittee.find(params[:client_id])
  	else
  		@vrc = VirtualReviewCommittee.first
  	end
  end

  def providers;end

  def provider_enrollment;end

  def enrollments;end

  def new_enrollment;end

  def all_clients;end

  def provider_clients;end

  def new_dco;end

  def enroll_new_user
  	# render ""
  end

  def new_group; end

  def new_group_enrollment;end

  def data_access
  	render "client_portal"
  end

		def settings
			@setting = Setting.take || Setting.new
		end

	protected

	def set_global_search
		global_search_data = []
		vrc_columns = VirtualReviewCommittee.column_names.dup.push('first_name', 'last_name', 'cred_cycle', 'provider_type', 'review_level', 'state')

		vrc_columns.each do |search_key|
			if params[search_key.to_sym].present?
				global_search_data << params[search_key.to_sym]
			end
		end
		@global_search_text = global_search_data.uniq.join(',')
	end


  def set_clients
    @page = params[:page] || 1
    @per_page = params[:per_page] || 100

    @status = params[:status] || nil
		if params[:none].present? && params[:none]['status'].present?
			@status = params[:none]['status'] || nil
		end

    @clients ||= if @status
       Client.where(cred_status: @status).paginate(per_page: @per_page, page: @page)
    else
    	 Client.all.paginate(per_page: @per_page, page: @page)
    end
  end

  def search_clients
  	global_search_data = []
  	client_columns = Client.column_names.dup.push('first_name', 'last_name', 'city', 'state', 'zipcode', 'npi', 'ssn', 'medv_id', 'cred_status', 'vrc_status')

  	client_columns.each do |search_key|
  		if params[search_key.to_sym].present?
  			global_search_data << params[search_key.to_sym]
  		end
  	end
  	@global_search_text = global_search_data.uniq.join(',')
  end

  def get_states
  	@states = State.all
  end

  def get_provider_types
  	@provider_types = ProviderType.all
  end

  def get_specialties
  	@specialties = Specialty.all
  end

  def get_languages
  	@languages = Language.all
  end

  def get_health_plans
  	@health_plans = HealthPlan.all
  	@hospitals = Hospital.all
  	@directories = Directory.all
  end

  def get_disclosures
  	@disclosures = DisclosureCategory.all
  end

  def get_practice_types
    @practice_types = PracticeType.all
  end

  def get_practitioner_profiles
    @profiles = PractitionerProfile.all
  end

  def get_services
    @services = Service.all
  end

	def get_education_types
    @education_types = EducationType.all
  end

  def set_provider
			if !ProviderSource.current.present?
				ProviderSource.last.update_columns current_provider_source: true, created_by_user: current_user.id
			end

			@provider = ProviderSource.current.is_a?(Array) ? ProviderSource.current_provider_source_by_current_user.last : ProviderSource.current_provider_source_by_current_user
		rescue
			nil
  end

  def has_incomplete_tabs
				set_provider unless @provider.present?

    tabs ||= [@provider.general_information_progress, @provider.professional_ids_progress, @provider.health_plans_progress,
            @provider.specialties_progress, @provider.education_traning_progess, @provider.affiliation_progress, @provider.professional_liability_progress,@provider.work_history_progress, @provider.disclosure_progress ]
    tabs = tabs.map{|tab| tab == 100}
    @has_incomplete ||= tabs.include?(false)
		rescue
					nil
  end

	def redirect_to_default_page
		# render json: current_role and return
		redirect_to_filtered_page(current_user.default_page) if current_user.default_page.present? && current_user.default_page != 'overview'
		render 'shared/access_denied' and return if current_user.default_page.blank?
	end

  def build_initial_associations
    @provider.create_dea if @provider&.deas&.reload&.blank?
    @provider.create_cds if @provider&.cds&.reload&.blank?
    @provider.create_registration if @provider&.registrations&.reload&.blank?
    @provider.create_cme if @provider&.cmes&.reload&.blank?
  end

  def new_association(model)
    @provider.create_dea if model == 'dea'
    @provider.create_cds if model == 'cds'
    @provider.create_registration if model == 'registration'
    @provider.create_cme if model == 'cme'
  end

  def delete_association_record(model, id)
    ProviderSourcesDea.delete(id) if model == 'dea'
    ProviderSourcesCds.delete(id) if model == 'cds'
    ProviderSourcesRegistration.delete(id) if model == 'registration'
    ProviderSourceCme.delete(id) if model == 'cme'

  end
end
