class GroupEngageProvidersController < ApplicationController
	before_action :set_group_engage_provider, only: [:add_to_roster]

	def create
		@group_engage_provider = GroupEngageProvider.new(group_engage_provider_params)

		if @group_engage_provider.save
			render json: {
				group_engage_provider: @group_engage_provider.decorate,
				message: 'New provider has been successfully created.'
			},	status: :created
		else
			render json: @group_engage_provider.errors.full_messages.to_sentence, status: :unprocessable_entity
		end
	end

	def search
		filter_params = group_engage_provider_params.except(:practice_location_id).reject { |k, v| v.blank? }.compact
		providers = GroupEngageProvider.search(filter_params.values.join(' '))

		render json: {
			providers: providers.map(&:decorate),
		},	status: :ok
	end

	def add_to_roster
		practice_location_id = params[:practice_location_id]

		if ProviderSource.exists?(practice_location_id: practice_location_id, group_engage_provider_id: @group_engage_provider.id)
			render json: 'Already	added to roster.',	status: :unprocessable_entity
		else
			provider_source = ProviderSource.find_or_create_by(practice_location_id: practice_location_id, group_engage_provider_id: @group_engage_provider.id)
			provider_source.add_to_roster(@group_engage_provider)

			render json: {
				practice_location_id: @group_engage_provider.practice_location_id,
				message: "Selected Provider used to be there in your roster, his/her record has just been activated. Invite email has not been sent."
			},	status: :ok
		end
	end

	protected
	def group_engage_provider_params
		params.require(:group_engage_provider).permit(:practice_location_id, :first_name, :middle_name, :last_name, :date_of_birth, :email_address, :ssn)
	end

	def set_group_engage_provider
		@group_engage_provider = GroupEngageProvider.find(params[:id])
	end
end
