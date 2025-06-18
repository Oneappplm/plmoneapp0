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
    @provider_source_documents = ProviderSourceDocument.where(provider_source_id: @provider.id)
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
      director_ids = params[:vrc_directors].map(&:to_i) || []
    end
    
    # selected_ids = params[:selected_ids][0].split(',').map(&:to_i) || []
    selected_ids = params[:selected_ids]&.map(&:to_i) || []

    review_date = params[:review_date]
    committee_date = params[:committee_date]

    if (director_ids.present? && selected_ids.present?) && (review_date.present? && committee_date.present?)
      director_ids.each do |director_id|
        selected_ids.each do |ppi_id|
          DirectorProvider.find_or_create_by(user_id: director_id, provider_personal_information_id: ppi_id )
        end
      end

      ProviderPersonalInformation.where(id: selected_ids).update_all(assigned_params.to_h) 
      redirect_to virtual_review_committee_path, notice: "Records are Assigned to Directors And Review and Committee dates updated successfully."

    elsif selected_ids.present? && review_date.present? && committee_date.present?
      ProviderPersonalInformation.where(id: selected_ids).update_all(assigned_params.to_h)
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
    # @provider_personal_informations = ProviderPersonalInformation.all
    @q = ProviderPersonalInformation.ransack(params[:q])
    @vrc_documents = VrcDocument.all
    @vrc_directors = User.directors
    @psv_pdf = SavedProfile.last

    # Apply search and filters via Ransack
    @provider_personal_informations = @q.result

    # Date range filtering
    if params[:review_date_from].present? && params[:review_date_to].present?
      @provider_personal_informations = @provider_personal_informations.where(review_date: Date.parse(params[:review_date_from])..Date.parse(params[:review_date_to]))
    end

    if params[:committee_date_from].present? && params[:committee_date_to].present?
      @provider_personal_informations = @provider_personal_informations.where(committee_date: Date.parse(params[:committee_date_from])..Date.parse(params[:committee_date_to]))
    end

    if params[:PSV_date_from].present? && params[:PSV_date_to].present?
      @provider_personal_informations = @provider_personal_informations.where(psv_completed_date: Date.parse(params[:PSV_date_from])..Date.parse(params[:PSV_date_to]))
    end

    # Progress status filter
    if params[:'vrc-progress-status'].present? && params[:'vrc-progress-status'] != 'all'
      @provider_personal_informations = @provider_personal_informations.send(params[:'vrc-progress-status'])
    end

    # Pagination
    @provider_personal_informations = @provider_personal_informations.paginate(page: params[:page], per_page: 50)

    # Conditional rendering based on `vrc` parameter
    case params[:vrc]
    when 'work-tickler'
      render 'work_tickler'
    when 'documents'
      render 'documents'
    when 'reports'
      render 'reports'
    when 'issue'
      render 'issue'
    when 'minutes'
      @completed_records = ProviderPersonalInformation.where(progress_status: "completed")
      render 'minutes'
    end
  end


  def records
    @vrc_directors = User.directors
    @provider_personal_informations = []
    
    if @params_present = params_present?

    elsif params[:selected_date].present?
      @selected_date = params[:selected_date]
      @provider_personal_informations = ProviderPersonalInformation.where(committee_date: @selected_date )
    elsif params[:selected_director].present?
      if params[:selected_director] == "All"
       @provider_personal_informations = ProviderPersonalInformation.all
      else 
         selected_director_id = params[:selected_director]
         @director = User.find(selected_director_id)     
         @provider_personal_informations = @director.provider_personal_informations
      end
    else
      @director = true
      @provider_personal_informations = ProviderPersonalInformation.all
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
      @completed_records = ProviderPersonalInformation.where(progress_status: "completed")
    end
  end 

	def client_portal
    if current_setting.mhc?
      redirect_to mhc_client_portal_index_path
    end
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

  # for downloading the clients data in client-portal(dashboard >> data access)
  def download_clients_data
    # provider_attest_id = params[:provider_attest_id]
    
    #  @provider_personal_informations = if provider_attest_id.present?
    #                                   ProviderPersonalInformation.where(provider_attest_id: provider_attest_id)
    #                                 else
    #                                   ProviderPersonalInformation.all
    #                                 end
    # @q = ProviderPersonalInformation.ransack(params[:q]&.except(:advanced_search))

    selected_ids = params[:selected_ids]&.split(',')

    @provider_personal_informations = if selected_ids.present?
                                   ProviderPersonalInformation.where(id: selected_ids)
                                 else
                                   ProviderPersonalInformation.all
                                 end


    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Provider Name', 'Birth Date', 'Address', 'Attested Date', 'MedvId', 'Cred Cycle']
      
      @provider_personal_informations.each do |provider|
       practice_information = provider&.provider_attest&.practice_informations&.first if provider&.provider_attest.present?
        csv << [
          "#{provider.fullname}, #{provider.provider_type_provider_type_abbreviation}",
          "#{provider.birth_date&.strftime("%Y-%m-%d")}",
          "#{practice_information&.complete_address}",
          "#{provider.attest_date&.strftime("%Y-%m-%d")}",
          "#{provider.caqh_provider_attest_id}",
          "#{practice_information&.cred_cycle}"
        ]
      end
    end
    respond_to do |format|
      format.csv { send_data csv_data, filename: "provider_report_#{Date.today}.csv" }
    end
  end


  # for downloading the vrc data in virtual-review-committee(dashboard >> decision point)
  def download_clients
    selected_ids = params[:selected_ids]&.split(',')

    @provider_personal_informations = if selected_ids.present?
                                   ProviderPersonalInformation.where(id: selected_ids)
                                 else
                                   ProviderPersonalInformation.all
                                 end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [
        'Encompass ID','Assigned','Provider Name', 'Provider Type', 'Cred Cycle', 'PSV Completed Date',
        'Review Level', 'Recred Due Date', 'Review Date', 'Committee Date',
        'Status'
      ]

      @provider_personal_informations.each do |ppi|
        csv << [
          ppi.caqh_provider_attest_id || ppi.provider_attest_id,
          ppi.progress_status,
          ppi.fullname,
          ppi.provider_type_provider_type_abbreviation,
          ppi.cred_cycle,
          ppi.attest_date&.strftime('%Y-%m-%d'),
          ppi.review_level,
          ppi.recred_due_date&.strftime('%Y-%m-%d'),
          ppi.review_date&.strftime('%Y-%m-%d'),
          ppi.committee_date&.strftime('%Y-%m-%d'),
          ppi.progress_status
        ]
      end
    end

    respond_to do |format|
      filename = selected_ids.present? ? "selected_providers_#{Date.today}.csv" : "all_providers_#{Date.today}.csv"
      format.csv { send_data csv_data, filename: filename }
    end
  end


  def show_virtual_review_committee
    if params[:id].present?
      @provider = ProviderPersonalInformation.find(params[:id])
      @provider_personal_informations = [@provider]
      @review_level_changes = @provider.review_level_changes.order(created_at: :desc)
      @psv_pdf = SavedProfile.last
    else
      @provider_personal_informations = ProviderPersonalInformation.all
      @provider = @provider_personal_informations.first
    end
  end

  # def record_approval
  #   @record = DirectorProvider.where(virtual_review_committee_id: params[:id])

  #   if @record
  #     if params[:status].present? && params[:status] != "Pending"
  #       @vrc = VirtualReviewCommittee.find(params[:id])
  #       if params[:other_checkbox] == "OTHER"
  #         desc = 'OTHER'
  #       else
  #         desc = params[:description]
  #       end
  #       @vrc.update(
  #         progress_status: "completed",
  #         review_details: desc,
  #         review_level: params[:status]
  #       )
  #     end
  #     redirect_to show_virtual_review_committee_path(params[:id]), notice: "Records updated successfully."
  #   else
  #     flash[:alert] = "There was an error updating the records."
  #     render :show_virtual_review_committee
  #   end
  # end

   def record_approval
    provider_params = params.require(:provider_personal_information).permit(:id, :status, :description)

    @provider = ProviderPersonalInformation.find_by(id: provider_params[:id])

    if @provider
      if provider_params[:status].present? && provider_params[:status] != "Pending"
        desc = (params[:other_checkbox].present? && provider_params[:description].present?) ? "OTHER" : provider_params[:description]

        old_level = @provider.review_level

        if @provider.update(progress_status: "completed", review_level: provider_params[:status], review_details: desc)
          
          @provider.review_level_changes.create!(
            changed_by: current_user.email, # or current_user.full_name
            from_level: old_level,
            to_level: provider_params[:status],
            reason: desc
          )

          redirect_to show_virtual_review_committee_path(@provider.id), notice: "Records updated successfully."
        else
          flash[:alert] = "Update failed: #{@provider.errors.full_messages.join(', ')}"
          render :show_virtual_review_committee
        end
      else
        redirect_to show_virtual_review_committee_path(@provider.id), notice: "No status change applied."
      end
    else
      flash[:alert] = "Provider not found."
      render :show_virtual_review_committee
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

  # for uploading and downloading the document in "VRC Document"

  def upload_vrc_document
    @vrc_document = VrcDocument.new(vrc_document_params)
    if @vrc_document.save
      redirect_to virtual_review_committee_path(vrc: 'documents'), notice: "Document uploaded successfully."
    else
      render :vrc_list_document, alert: "Failed to upload document."
    end
  end

  def update_vrc_document
    document = VrcDocument.find(params[:document_id])
    if document.update(vrc_document_params)
      redirect_to virtual_review_committee_path(vrc: 'documents'), notice: "Document updated successfully."
    else
      redirect_to virtual_review_committee_path(vrc: 'documents'), alert: 'Document or file not found.'
    end
  end

  def delete_vrc_documents
    document = VrcDocument.find(params[:id])
    if document && document.destroy
      flash[:notice] = 'Document was successfully deleted.'
      render json: { success: true }
    else
      flash[:alert] = 'Failed to delete the document.'
      render json: { success: false }, status: :not_found
    end
  end


    # @vrc_document = VrcDocument.find(params[:id])
    # if @vrc_document.destroy
    #   redirect_to virtual_review_committee_path(vrc: 'documents'), notice: "Document deleted successfully."
    # else
    #   redirect_to virtual_review_committee_path(vrc: 'documents'), alert: "Failed to delete the document."
    # end


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

    # def record_approval_params
    #   params.permit(:status, :description, :signature_upload)
    # end

    def vrc_document_params
      params.permit(:name, :committee_date, :file_upload)
    end


end

