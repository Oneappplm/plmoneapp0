module ApplicationHelper
	def active_menu cname, aname = nil
		if aname.present?
			cname.split(',').include?(controller_name) && aname.split(',').include?(action_name) ? 'ph-active fw-semibold' : ''
		else
			cname.split(',').include?(controller_name) ? 'ph-active fw-semibold' : ''
		end
	end

	def current_provider_source
		@current_provider_source ||= ProviderSource.find_or_create_by(current_provider_source: true)
	end

	# def active_menu_old cname, aname
	# 	cname == controller_name && aname.split(',').include?(action_name) ? 'ph-active' : ''
	# end

	def active_submenu cname, aname
		(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? '' : 'd-none'
	end

	def chevron_active cname, aname
		(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'rotate-chev' : ''
	end

	def active_submenu_link cname, aname
		cname == controller_name && aname.split(',').include?(action_name) ? 'link_active fw-semibold' : ''
	end

	def enrollment_nav_active aname
		aname.split(',').include?(action_name) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
	end
end
