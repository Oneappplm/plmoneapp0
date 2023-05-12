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

	def enrollment_nav_active cname, aname = nil
		if aname.present?
			(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		else
			cname.split(',').include?(controller_name) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		end
	end

	def enrollment_nav_active_old aname, cname = nil
		if cname.present?
			(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		else
			aname.split(',').include?(action_name) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		end
	end

	def current_setting
		@current_setting ||= Setting.take || Setting.new
	end

	def dark_mode
		if current_setting.dark_mode.downcase == 'yes'
			'bg-dark'
		else
			current_setting.theme_color.present? ? 'bg-theme-color' : 'bg-white'
		end
	rescue
		'bg-white'
	end

	def is_edit_mode?
	['edit', 'update'].include?(action_name)
	end

	def mixed_providers_options
		providers = Provider.all + ProviderSource.all
		providers.map{|p| ["#{p.provider_name} from #{p.from_provider_title}", p.id]}
	end

	# memoization
	def states
		@states ||= State.all
	end

	def provider_types
		@provider_types ||= ProviderType.all
	end

	def health_plans
		@health_plans ||= HealthPlan.all
	end

	def yes_or_no_options
		[
			['Yes', 'yes'],
			['No', 'no']
		]
	end

	def active_or_inactive_options
		[
			['Active', 'active'],
			['Inactive', 'inactive']
		]
	end

  def enrollment_status_options
    [
      ['Submitted','submitted'],
      ['Not Submitted','not_submitted'],
      ['Approved','approved'],
      ['Rejected','rejected']
    ]
  end
end
