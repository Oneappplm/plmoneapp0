class GroupEngageProvider::CreateProviderSourceService < GroupEngageProvider::BaseService
  attr_reader :provider_source, :group_engage_provider, :current_user

  def initialize(group_engage_provider, current_user)
    @group_engage_provider = group_engage_provider
    @current_user = current_user

    provider_personal_info = ProviderPersonalInformation.new(
      first_name: group_engage_provider.first_name,
      last_name: group_engage_provider.last_name,
      ssn: group_engage_provider.ssn,
      birth_date: group_engage_provider.date_of_birth,
      middle_name: group_engage_provider.middle_name,
      email_address: group_engage_provider.email_address,
      caqh_provider_id: rand(10**8).to_s.rjust(8, '5'),
      provider_attest_id: rand(10**8).to_s.rjust(8, '5'),
      caqh_provider_attest_id: rand(10**8).to_s.rjust(8, '5'),
      created_by: 'group-engage',
      cred_status: 'incomplete'
    )

    provider_personal_info.save(validate: false)

    provider_attest = ProviderAttest.create!(
      id: provider_personal_info.provider_attest_id,
      caqh_provider_attest_id: provider_personal_info.caqh_provider_attest_id
    )

    provider_personal_info.update(provider_attest_id: provider_attest.id)
    @provider_source = ProviderSource.new(
      group_engage_provider_id: group_engage_provider.id,
      provider_personal_information_id: provider_personal_info.id,
      created_by_user: current_user&.id,

    )
  end

  def call
    return error!("#{group_engage_provider.full_name} is already added in the Provider Engage.") if ProviderSource.exists?(group_engage_provider_id: group_engage_provider.id)

    save_provider_source_and_data_fields
  end

  protected

  def save_provider_source_and_data_fields
    if provider_source.save
      provider_source.increment!(:invitation_count)
      provider_source.update(invitation_sent_at: Time.now)

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
end
