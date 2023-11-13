PARENT_MENUS = ['overview', 'dashboard', 'provider_engage', 'group_engage', 'enrollment_dashboard', 'enrollment_tracking', 'verification_platform',  'role_based_access']
SUB_MENUS = {
	overview: [],
	dashboard: ['data_access', 'decision_point'],
	provider_engage: [],
	group_engage: ['manage_provider', 'manage_practice'],
	enrollment_dashboard: ['ed_dashboard', 'groups', 'provider_data', 'reports', 'notifications'],
	enrollment_tracking: ['et_overview', 'providers', 'enrollment', 'group', 'et_notification'],
	verification_platform: ['client_home', 'manage_client', 'manage_practitioner', 'manage_tools', 'query_report', 'work_tickler', 'manage_db', 'autoverify'],
	role_based_access: ['users', 'role_access']
}