class Users::SecurityQuestionsController < ApplicationController
  layout 'authentication'
  before_action :authenticate_user!

  def edit; end

  def update
    if current_user.update(security_questions_params)
      redirect_to root_path, notice: "Security questions set successfully."
    else
      redirect_to edit_security_question_path(current_user), error: "Something went wrong."
    end
  end

  private

  def security_questions_params
    params.require(:user).permit(:security_question, :security_answer)
  end
end
