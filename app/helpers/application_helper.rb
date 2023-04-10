module ApplicationHelper
	def active_menu cname, aname
		cname == controller_name && aname.split(',').include?(action_name) ? 'ph-active' : ''
	end

	def current_provider_source
		@current_provider_source ||= ProviderSource.find_or_create_by(current_provider_source: true)
	end
end
