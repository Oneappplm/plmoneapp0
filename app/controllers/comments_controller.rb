class CommentsController < ApplicationController

  def create
    comment = EnrollmentComment.new(comment_params)

    if comment.save
      redirect_to request.referrer
    end
  end

  private

  def comment_params
    params.require(:enrollment_comment).permit(:body, :enrollment_provider_id, :enroll_group_id, :user_id, :provider_id)
  end

end