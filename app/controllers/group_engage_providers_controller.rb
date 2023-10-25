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
		filter_params = group_engage_provider_params.reject { |k, v| v.blank? }.compact

		providers = []
		provider_source_ids =	[]
		# group_enage_providers = GroupEngageProvider.search(filter_params.values.join(' '))

		first_name	= filter_params[:first_name]
		last_name	= filter_params[:last_name]
		date_of_birth	= filter_params[:date_of_birth]

		provider_source_data = ProviderSourceData.where(data_key: ['first_name', 'last_name', 'date_of_birth'])

		provider_source_data.each	do |provider_source_datum|
			if	provider_source_datum.data_key == 'first_name'	&& provider_source_datum.data_value == first_name ||
				provider_source_datum.data_key == 'last_name'	&& provider_source_datum.data_value == last_name ||
				provider_source_datum.data_key == 'date_of_birth'	&& provider_source_datum.data_value == date_of_birth
					provider_source_ids << provider_source_datum.provider_source_id
			end
		end

		# group engage providers
		# group_enage_providers.each do |group_enage_provider|
		# 	filtered_group_enage_provider_data = {id: group_enage_provider.id, type: 'Group Engage'}

		# 	data_keys = ['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn']
		# 	data_keys.each do |data_key|
		# 		filtered_group_enage_provider_data[data_key.to_sym] = filtered_data_value(group_enage_provider.send(data_key))
		# 	end

		# 	providers << filtered_group_enage_provider_data
		# end

		# provider source
		provider_sources = ProviderSource.where(id: provider_source_ids)
		data_keys = ['first_name', 'middle_name', 'last_name', 'ps-dob', 'social-security-number', 'email_address']
		provider_sources.each do |provider_source|
			filtered_provider_source_data = {id: provider_source.id, type: 'Provider Engage'}

			data_keys.each do |data_key|
				filtered_provider_source_data[filtered_data_key(data_key).to_sym] = filtered_data_value(provider_source.fetch(data_key))
			end

			providers << filtered_provider_source_data
		end

		render json: {
			providers: providers,
		},	status: :ok
	end

	def filtered_data_key	data_key
		case data_key
		when 'ps-dob'
			'date_of_birth'
		when 'social-security-number'
			'ssn'
		when 'email'
			'email_address'
		else
			data_key
		end
	end

	def filtered_data_value data_value
		if data_value.present? && (data_value.is_a?(Date) || data_value.is_a?(Time) || data_value.match?(/\d{4}-\d{2}-\d{2}/))
			data_value.to_datetime.strftime('%m/%d/%Y')
		elsif data_value.nil?
			''
		else
			data_value
		end
	end

	def add_to_roster
		if ProviderSource.exists?(practice_location_id: @practice_location_id, group_engage_provider_id: @group_engage_provider.id)
			render json: 'Already	added to roster.',	status: :unprocessable_entity
		else
			if @type	== 'Provider Engage'
				provider_source = @group_engage_provider.provider_source
				provider_source.update practice_location_id: @practice_location_id
			else
				provider_source = ProviderSource.find_or_create_by(practice_location_id: @practice_location_id, group_engage_provider_id: @group_engage_provider.id)
			end

		 provider_source.add_to_roster(@group_engage_provider)

			@group_engage_provider.update_columns practice_location_id: @practice_location_id

			render json: {
				practice_location_id: @group_engage_provider.practice_location_id,
				message: "Selected Provider used to be there in your roster, his/her record has just been activated. Invite email has not been sent."
			},	status: :ok
		end
	end

	protected
	def group_engage_provider_params
		params.require(:group_engage_provider).permit(:first_name, :middle_name, :last_name, :date_of_birth, :email_address, :ssn)
	end

	def set_group_engage_provider
		@type	= params[:type]
		@practice_location_id = params[:practice_location_id]

		if @type	== 'Provider Engage'
			provider_source = ProviderSource.find params[:id]
			@group_engage_provider = GroupEngageProvider.new
			data_keys = ['first_name', 'middle_name', 'last_name', 'ps-dob', 'social-security-number', 'email_address']
			data_keys.each do |data_key|
				@group_engage_provider.send("#{filtered_data_key(data_key)}=", provider_source.fetch(data_key))
			end
			@group_engage_provider.skip_create_provider_source	= true

			if @group_engage_provider.save(validate: false)
				provider_source.increment!(:invitation_count)
				provider_source.update_columns(
					group_engage_provider_id: @group_engage_provider.id,
					invitation_sent_at: Time.now,
				)
			end
		else
			@group_engage_provider = GroupEngageProvider.find(params[:id])
		end
	end
end
