class Users::SessionsController < Devise::SessionsController
	before_action :can_create?, except: [:new, :create]
	def create

		self.resource = warden.authenticate!(auth_options)
		set_flash_message!(:notice, :signed_in)
		# binding.break
		sign_in(resource_name, resource)
		yield resource if block_given?
		respond_with resource, location: after_sign_in_path_for(resource)
	end
end