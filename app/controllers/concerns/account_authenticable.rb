module AccountAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_account!, except: %i[terms privacy_policy]
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :ensure_security_questions_set, if: :user_signed_in?

    helper_method :current_account, :account_signed_in?, :user_admin?
  end

  protected

  def current_account
    current_user || current_admin
  end

  def account_signed_in?
    user_signed_in? || admin_signed_in?
  end

  def authenticate_account!
    return if account_signed_in?
    return if request.path == new_user_session_path || request.path == new_admin_session_path

    redirect_to new_user_session_path, alert: "You need to sign in before continuing."
  end

  def current_user
    current_admin || super
  end

  def user_signed_in?
    admin_signed_in? || super
  end

  def authenticate_user!
    authenticate_account!
  end

  def user_admin?
    account_signed_in? && current_account.is_a?(Admin)
  end

  def configure_permitted_parameters
    update_params = [:first_name, :last_name, :user_type, :password, :password_confirmation, :current_password, :security_question, :security_answer]

    devise_parameter_sanitizer.permit(:account_update, keys: update_params)
		devise_parameter_sanitizer.permit(:sign_up, keys: update_params)
  end
end
