class Users::PasswordsController < Devise::PasswordsController
	def update
		super do |resource|
			if resource.errors.empty?
				resource.update(password_change_status_via_invite: 'completed') if	resource.password_change_status_via_invite == 'pending'
			end
		end
	end
end