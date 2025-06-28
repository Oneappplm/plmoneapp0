class ProviderSources::SendInviteService < ProviderSource::BaseService
	attr_reader :user, :params, :group_engage_provider

	def initialize(provider_source, params)
		super(provider_source)

		@group_engage_provider = provider_source.group_engage_provider
		@user = @group_engage_provider&.user
		@params = params
	end

	def check_errors
		send_error "Invalid provider data, this provider should be added from the group engage." if group_engage_provider.blank?
		send_error "No user linked to this provider, remove this provider and add from group engage." if user.blank?
	end

	def process_data
		# send email invitation with reset password link
		user.send_invite_and_reset_password_instructions(params)

		# this status is use for checking if the user has already change the password and click the link in the email
		# will change to 'completed' once the user has change the password
		user.update(password_change_status_via_invite: 'pending')

		# update the invitation count to know	how many times the user has been invited
		provider_source.increment!(:invitation_count)

		# update the invitation sent at to know when the user has been invited last
		provider_source.update(invitation_sent_at: Time.now)
	end

	def filtered_response
		{ message: "Invitation sent successfully." }
	end
end
