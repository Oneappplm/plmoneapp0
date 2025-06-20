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

  def update_review_committee_dates
    if params[:vrc_directors].present?
      vrc_director_ids = params[:vrc_directors].map(&:to_i)
    end
    
    selected_ids = params[:selected_ids][0].split(',').map(&:to_i)

    review_date = params[:review_date]
    committee_date = params[:committee_date]

    if (vrc_director_ids.present? && selected_ids.present?) && (review_date.present? && committee_date.present?)
      vrc_director_ids.each do |director_id|
        selected_ids.each do |virtual_review_committee_id|
          DirectorProvider.create(user_id: director_id, virtual_review_committee_id: virtual_review_committee_id )
        end
      end

      VirtualReviewCommittee.where(id: selected_ids).update_all(assigned_params.to_h) 
      redirect_to virtual_review_committee_path, notice: "Records are Assigned to Directors And Review and Committee dates updated successfully."

    elsif selected_ids.present? && (review_date.present? && committee_date.present?)
      VirtualReviewCommittee.where(id: selected_ids).update_all(assigned_params.to_h)
      redirect_to virtual_review_committee_path, notice: "Review and Committee dates updated successfully."
    else
      flash[:error] = 'Invalid parameters.'
      redirect_to virtual_review_committee_path, notice: 'There is an error.'
    end

  end

  def unassigned_records
    selected_ids = params[:selected_ids][0].split(',').map(&:to_i)
    puts "Selected IDs: #{selected_ids.inspect}"
    VirtualReviewCommittee.where(id: selected_ids).update_all(progress_status: 'to_be_assigned')

    redirect_to virtual_review_committee_path, notice: 'Assignments have been successfully removed'
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
    @vrc_directors = User.directors

		@vrcs = if @global_search_text.present?
			VirtualReviewCommittee.search(@global_search_text)
		else
			VirtualReviewCommittee.all
		end

    if (params[:review_date_from].present? && params[:review_date_to].present?) && (params[:committee_date_from].present? && params[:committee_date_to])&&params[:PSV_date_from].present? && params[:PSV_date_to].present?
        review_date_range = Date.parse(params[:review_date_from])..Date.parse(params[:review_date_to])
        committee_date_range = Date.parse(params[:committee_date_from])..Date.parse(params[:committee_date_to])
        psv_date_range = Date.parse(params[:PSV_date_from])..Date.parse(params[:PSV_date_to])
        @vrcs = @vrcs.where(review_date: review_date_range, committee_date: committee_date_range, psv_completed_date: psv_date_range)

    elsif (params[:review_date_from].present? && params[:review_date_to].present?)
        review_date_range = Date.parse(params[:review_date_from])..Date.parse(params[:review_date_to])
        @vrcs = @vrcs.where(review_date: review_date_range)

    elsif (params[:committee_date_from].present? && params[:committee_date_to].present?)
        committee_date_range = Date.parse(params[:committee_date_from])..Date.parse(params[:committee_date_to])
        @vrcs = @vrcs.where(committee_date: committee_date_range)

    elsif (params[:PSV_date_from].present? && params[:PSV_date_to].present?)
      psv_date_range = Date.parse(params[:PSV_date_from])..Date.parse(params[:PSV_date_to])
       @vrcs = @vrcs.where(psv_completed_date: psv_date_range)

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
    elsif params[:vrc].present? && params[:vrc] == 'minutes'
      @completed_records = VirtualReviewCommittee.where(progress_status: "completed")
      render 'minutes'
		end
	end

  def records
    @vrc_directors = User.directors
    
    if @params_present = params_present?

    elsif params[:selected_date].present?
      @selected_date = params[:selected_date]
      @selected_committee_dates = VirtualReviewCommittee.where(committee_date: @selected_date )
    elsif params[:selected_director].present?
      if params[:selected_director] == "All"
       
      else 
         selected_director_id = params[:selected_director]
         @director = User.find(selected_director_id)     
      end
    else
      @director = true
    end

    render 'work_tickler'
  end

  def params_present?
      params[:review_level].present? || params[:provider_type].present? || params[:cred_cycle].present? ||
      params[:form_committee_date].present? || params[:to_committee_date].present? ||
      params[:first_name].present? || params[:last_name].present? 
  end

  def minutes
    if params_present?.present?
      @params_present = params_present?
    else
      @completed_records = VirtualReviewCommittee.where(progress_status: "completed")
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
    elsif params[:id].present?
      @vrc = VirtualReviewCommittee.find(params[:id])
  	else
  		@vrc = VirtualReviewCommittee.first
  	end
  end

  def record_approval
    @record = DirectorProvider.where(virtual_review_committee_id: params[:id])

    if @record.update(record_approval_params)
     if record_approval_params[:status] != "Pending"
        @vrc = VirtualReviewCommittee.find(params[:id]).update(progress_status: "completed")
      end
      redirect_to virtual_review_committee_path
    else
      render :show_virtual_review_committee, notice: "There was an error updating the records."
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

  private
  	def assigned_params
  	  params.permit(:review_date, :committee_date, :progress_status)
  	end

    def unassigned_params
      params.permit(:progress_status)
    end

    def record_approval_params
      params.permit(:status, :description, :signature_upload)
    end
end

