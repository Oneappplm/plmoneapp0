class Users::PasswordsController < Devise::PasswordsController
  def new
    redirect_to root_path if current_setting.qualifacts?

    super
  end
  def edit
    super
    @user_security_question = User.with_reset_password_token(params[:reset_password_token])&.security_question
  end

  def update
    user = User.with_reset_password_token(params[:user][:reset_password_token])
    security_answer = params[:user][:security_answer]

    if security_answer.present?
      if user && valid_security_answer?(user, security_answer)
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, :updated)
          redirect_to new_user_session_path
        else
          respond_with resource
        end
      else
        redirect_to edit_user_password_url(reset_password_token: params[:user][:reset_password_token]), alert: 'Security answer was incorrect.'
      end
    else
      # Handles the existing implementation to reset the password via invite
      super do |resource|
        if resource.errors.empty?
        resource.update(password_change_status_via_invite: 'completed') if	resource.password_change_status_via_invite == 'pending'
        end
      end
    end
  end

  private

  def valid_security_answer?(user, security_answer)
    user.security_answer == security_answer
  end
end
