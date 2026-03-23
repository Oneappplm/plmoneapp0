class GroupEngageProvider::CreateUserService < GroupEngageProvider::BaseService
  attr_reader :user, :group_engage_provider, :current_user

  def initialize(group_engage_provider, current_user)
    @group_engage_provider = group_engage_provider
    @current_user = current_user

    if User.exists?(email: group_engage_provider.email_address)
      raise StandardError, "User already exists with this email"
    end

    @user = User.new

    delete_uncessary_fields
    setup_user
    setup_password_token
  end

  def call
    unless user.save
      raise StandardError, user.errors.full_messages.join(', ')
    end

    user.send_reset_password_instructions
    user.update_columns(password_change_status_via_invite: 'pending')
    group_engage_provider.update(user_id: user.id)
  end

  protected

  def setup_user
    user.email = group_engage_provider.email_address
    user.first_name = group_engage_provider.first_name
    user.last_name = group_engage_provider.last_name
    user.middle_name = group_engage_provider.middle_name

    user.user_role = 'provider'
    user.status = 'Active'
    user.define_singleton_method(:password_required?) { false }
  end

  def setup_password_token
    user.reset_password_token = Devise.friendly_token
    user.reset_password_sent_at = Time.now.utc
  end

  def delete_uncessary_fields
    return unless group_engage_initial_fields.present?

    group_engage_initial_fields.delete('date_of_birth')
    group_engage_initial_fields.delete('ssn')
  end

  def filtered_data_key(column)
    column == 'email_address' ? 'email' : column
  end
end
