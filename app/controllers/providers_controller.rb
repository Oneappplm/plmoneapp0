class ProvidersController < ApplicationController
	before_action :set_provider, only: [:show, :edit, :update, :destroy]
	before_action :initialize_collections_data, only: [:new, :edit, :create, :update]
	before_action :get_states, only: [:new, :edit, :index, :create]
	def index
			@providers = Provider.all
	end

	def new
			@provider = Provider.new
			build_associations
	end

	def edit
		build_associations
	end

	def create
			@provider = Provider.new(provider_params)

			if @provider.save
					redirect_to providers_path
			else
				 build_associations
					render :new
			end
	end

	def update
		if @provider.update(provider_params)
				redirect_to providers_path, notice: 'Provider was successfully updated.'
		else
			 build_associations
				render :edit
		end
end

	def destroy
			if @provider.destroy
				redirect_to providers_path, notice: 'Successfully deleted'
			else
				redirect_to providers_path, alert: 'Something went wrong'
			end
	end

  def show
      @providers = Provider.all
      @provider = Provider.find(params[:id])
  end

	private

	def set_provider
			@provider = Provider.find(params[:id])
	end

	def initialize_collections_data
		@provider_types = ProviderType.all
		@specialties = Specialty.all
	end

	def build_associations
		@provider.taxonomies.build
		@provider.licenses.build
		@provider.np_licenses.build
		@provider.rn_licenses.build
	end

	def provider_params
			params.require(:provider).permit(
					:first_name,
					:middle_name,
					:last_name,
					:suffix,
					:gender,
					:birth_date,
					:practitioner_type,
					:ssn,
					:npi,
					:caqhid,
					:caqh_attestation_date,
					:caqh_pdf,
					:caqh_pdf_date_received,
					:nccpa_number,
					:dea_number,
					:dea_license_effective_date,
					:dea_license_expiration_date,
					:dco,
					:dco_file,
					taxonomies_attributes: [:id, :taxonomy_code, :specialty, :_destroy],
					licenses_attributes: [:id, :license_number, :license_effective_date, :license_expiration_date, :_destroy],
					np_licenses_attributes: [:id, :np_license_number, :np_license_effective_date, :np_license_expiration_date, :_destroy],
					rn_licenses_attributes: [:id, :rn_license_number, :rn_license_effective_date, :rn_license_expiration_date, :_destroy]
			)
	end

	def get_states
		@states = State.all
	end
end
