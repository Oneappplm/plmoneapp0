class RoleBasedAccess < ApplicationRecord
	PAGES = [
		:overview,
		:client_portal,
		:provider_app,
		:office_manager,
		:enrollment_tracking,
		:verification_platform,
		:plm_sales_tool,
		:smart_contract,
		:settings,
		:manage_clients,
		:manage_practitioners,
		:work_ticklers,
		:enrollment_clients,
		:notifications,
        :notification_bell,
        :enrollment_details_notes,
		:enrollment_groups,
		:locations,
		:alt_enrollment_groups,
	]
	CRUD = [:create, :read, :update, :delete]

	ROLE_ACCESS = [
    "Overview",
    "Notification-bell",
    "Enrollment Details Notes",
    "Dashboard",
    "Data Access",
    "Decision Point",
    "Provider Engage",
    "Group Engage",
    "Manage Provider",
    "Send Invite",
    "Add Provider",
    "Remove Provider",
    "Manage Application",
    "Remove Location",
    "Manage Practice",
    "Edit Organization",
    "Add Location",
    "Edit Location",
    "Associate Providers",
    "Enrollment Dashboard",
    "ED Dashboard",
    "Groups",
    "Group Details",
    "Group Enrollment",
    "Group Documents",
    "Location",
    "Location Details",
    "Group Providers",
    "Provider Data",
    "Provider Profile",
    "Provider Enrollment Details",
    "Uploaded Documents",
    "Reports",
    "Notifications",
    "Enrollment Tracking",
    "ET Overview",
    "Generate Report",
    "Providers",
    "Add New Provider",
    "Edit Provider",
    "Delete Provider",
    "View Provider Sidebar",
    "Enrollment",
    "Add New Enrollment",
    "Edit Enrollment",
    "Delete Enrollment",
    "View Enrollment Sidebar",
    "Group",
    "Add New Group",
    "Edit Group",
    "Delete Group",
    "Add New Location",
    "Edit Location",
    "Delete Location",
    "View Location Sidebar",
    "ET Notification",
    "Missing Required Fields",
    "Missing Documents",
    "New Provider Group",
    "Provider Group Updated",
    "Provider Group Deleted",
    "Verification Platform",
    "Client Home",
    "Manage Client",
    "Manage Practitioner",
    "Manage Tools",
    "Query Report",
    "Work Tickler",
    "Manage DB",
    "Autoverify",
    "Role Based Access",
    "Users",
    "Add New User",
    "Add New Role",
    "Edit User",
    "Delete User",
    "Select Role",
    "Role Access",
    "Edit Access",
    "Delete Role",
    "Associate Location",
	"Settings",
    "App Trackers"
	]

	default_scope { order(:id) }

  has_many :users, class_name: 'User', foreign_key: 'user_role', primary_key: 'role'
  has_one :parent_role, class_name: 'Role', foreign_key: 'slug', primary_key: 'role'

	class << self
		def initialize_access(role_based = 'super_administrator')
			return unless role_based.present?

			role_access_data.each do |page|
				RoleBasedAccess.find_or_create_by(role: role_based, page: page.first.to_s)
			end

			if role_based == 'super_administrator'
				RoleBasedAccess.where(role: role_based).each	do |role_based_access|
					role_based_access.update_attribute(:can_read, true) if role_based_access.can_read.nil?
				end
			end
		end

		def role_access_data
			ROLE_ACCESS.map{|x| {
					"#{x.parameterize(separator: '_')}": x
			} }.reduce({}, :merge)
		end

		def find_role_access_key(role_access)
			role_access_data.find{|k, v| v == role_access}.first.to_s
		rescue
				nil
		end

		def find_role_access(current_role, role_access)
			RoleBasedAccess.find_by(role: current_role, page: find_role_access_key(role_access))
		end
	end
end