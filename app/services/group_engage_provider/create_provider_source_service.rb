class GroupEngageProvider::CreateProviderSourceService < GroupEngageProvider::BaseService
  attr_reader :provider_source, :group_engage_provider, :current_user

  def initialize(group_engage_provider, current_user)
    @group_engage_provider = group_engage_provider
    @current_user = current_user

    # ✅ STEP 1: Find or initialize PPI (use unique fields)
    provider_personal_info = ProviderPersonalInformation.find_or_initialize_by(
      email_address: group_engage_provider.email_address
    )

    is_new_record = provider_personal_info.new_record?

    # ✅ STEP 2: Assign attributes (only overwrite if needed)
    provider_personal_info.assign_attributes(
      first_name: group_engage_provider.first_name,
      last_name: group_engage_provider.last_name,
      ssn: group_engage_provider.ssn,
      birth_date: group_engage_provider.date_of_birth,
      middle_name: group_engage_provider.middle_name,
      created_by: 'group-engage',
      cred_status: 'incomplete'
    )

    # ✅ STEP 3: Generate IDs ONLY if new
    if is_new_record
      provider_personal_info.caqh_provider_id        ||= generate_unique_id(:caqh_provider_id)
      provider_personal_info.provider_attest_id     ||= generate_unique_id(:provider_attest_id)
      provider_personal_info.caqh_provider_attest_id ||= generate_unique_id(:caqh_provider_attest_id)
    end

    provider_personal_info.save(validate: false)

    # ✅ STEP 4: Create ProviderAttest ONLY if not exists
    if is_new_record
      ProviderAttest.find_or_create_by!(
        id: provider_personal_info.provider_attest_id
      ) do |attest|
        attest.caqh_provider_attest_id = provider_personal_info.caqh_provider_attest_id
      end
    end

    # ✅ STEP 5: Create ProviderSource (no duplicate)
    @provider_source = ProviderSource.find_or_initialize_by(
      group_engage_provider_id: group_engage_provider.id
    )

    @provider_source.assign_attributes(
      provider_personal_information_id: provider_personal_info.id,
      created_by_user: current_user&.id
    )
  end

  def call
    return error!("#{group_engage_provider.full_name} is already added in the Provider Engage.") if provider_source.persisted?

    save_provider_source_and_data_fields
  end

  protected

  def save_provider_source_and_data_fields
    if provider_source.save
      provider_source.increment!(:invitation_count)
      provider_source.update(invitation_sent_at: Time.current)

      fields = group_engage_initial_fields.presence || %w[first_name last_name email_address]

      fields.each do |column|
        data_key = filtered_data_key(column)
        value = group_engage_provider.send(column)

        next if value.blank?

        provider_source.add_data(data_key, value)

        if column == 'ssn' && group_engage_provider.ssn.present?
          provider_source.add_data('ps-ssn', 'yes')
        end
      end
    end
  end

  # ✅ Helper for unique ID generation
  def generate_unique_id(column)
    loop do
      value = rand(10**8).to_s.rjust(8, '5')
      break value unless ProviderPersonalInformation.exists?(column => value)
    end
  end
end
