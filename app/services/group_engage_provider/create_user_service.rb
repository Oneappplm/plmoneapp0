class GroupEngageProvider::CreateUserService < GroupEngageProvider::BaseService
	attr_reader :user

	def	initialize(group_engage_provider)
		super
		@user = User.find_by(email: group_engage_provider.email_address) || User.new

		delete_uncessary_fields
		setup_user
		setup_password_token
	end
	def call
		if user.save
  	user.send_reset_password_instructions
			group_engage_provider.update(user_id: user.id)
		else
			error!(user.errors.full_messages.join(', '))
		end
	end

	protected

	def setup_user
		group_engage_initial_fields.each do |column|
			user_column = filtered_data_key(column)
			user.send("#{user_column}=", group_engage_provider[column])
		end
		user.user_role = 'provider'
		user.status = 'Active'
		user.define_singleton_method(:password_required?) { false }
	end

	def setup_password_token
		user.reset_password_token = Devise.friendly_token
  user.reset_password_sent_at = Time.now.utc
	end

	def delete_uncessary_fields
		group_engage_initial_fields.delete('date_of_birth')
		group_engage_initial_fields.delete('ssn')
	end

	def filtered_data_key column
		case column
		when 'email_address'
			'email'
		else
			column
		end
	end
end
