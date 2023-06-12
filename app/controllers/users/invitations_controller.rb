class Users::InvitationsController < Devise::InvitationsController
	def update
		# set temporary_password same to password confirmation on params
		params[:user][:temporary_password] = params[:user][:password_confirmation]

		self.resource = resource_class.accept_invitation!(update_resource_params)

		if resource.errors.empty?
				# Invitation accepted successfully
				flash[:notice] = "Invitation accepted. You are now signed in."
				sign_in(resource)
				redirect_to after_accept_path_for(resource)
		else
				# Error accepting invitation
				flash[:alert] = "Error accepting invitation."
				redirect_to root_path
		end
end

# def accept_resource
# 	resource = resource_class.accept_invitation!(update_resource_params)

# 	# Report accepting invitation to analytics
# 	# Analytics.report('invite.accept', resource.id)
# 	resource
# end

private

	def update_resource_params
			params.require(:user).permit(:password, :password_confirmation, :temporary_password, :invitation_token)
	end
end