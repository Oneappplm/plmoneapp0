class PagesController < ApplicationController
	before_action :set_global_search, only: [:virtual_review_committee]
  before_action :set_clients, only: %i[client_portal show_client_details]
  before_action :search_clients, only: %i[client_search]
  before_action :search_inputs, only: %i[client_search client_portal]
  before_action :get_states, only: %i[client_search client_portal virtual_review_committee provider_source]
  before_action :get_provider_types, only: %i[client_search client_portal virtual_review_committee provider_source]
  before_action :get_specialties, only: %i[client_search client_portal virtual_review_committee provider_source]
  before_action :get_languages, only: %i[provider_source]
  layout "public_application", only: %i[terms privacy_policy]

	def provider_source
		if params[:page].present?
			render "pages/provider_source/#{params[:page]}"
		end
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

		@vrcs = @vrcs.paginate(page: params[:page], per_page: 5)

		if params[:vrc].present? && params[:vrc] == 'work-tickler'
			render 'work_tickler'
		elsif params[:vrc].present? && params[:vrc] == 'documents'
			render 'documents'
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
		@clients = @clients.paginate(per_page: 10, page: params[:page] || 1)
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
    @per_page = params[:per_page] || 10

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
end