module ApplicationHelper
	def active_menu cname, aname
		cname == controller_name && aname.split(',').include?(action_name) ? 'ph-active' : ''
	end
end
