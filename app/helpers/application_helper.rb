
module ApplicationHelper
	def can_read?
		return if current_role&.can_read || !current_user

		render 'shared/access_denied' and return
	end

	def can_create?
		return if current_role&.can_create || !current_user

		render 'shared/access_denied' if current_user and return
	end

	def can_update?
		return if current_role&.can_update || !current_user

		render 'shared/access_denied' if current_user and return
	end

	def	can_delete?
		return if current_role&.can_delete || !current_user

		render 'shared/access_denied' if current_user and return
	end

	def can_view? page
	 find_role(page)&.can_read
	end

	def translate_page(page = nil)
		page =	page || controller_name
		if ['dashboard'].include?(controller_name)
			'overview'
		elsif ['providers', 'auto_verifies', 'logs'].include?(controller_name)
			if ['overview', 'index', 'show'].include?(action_name)
				'enrollment_tracking'
			else
			'provider_app'
			end
		elsif ['enrollment_providers', 'enroll_groups', 'dcos', 'groups', 'client_provider_enrollments'].include?(controller_name)
			'enrollment_tracking'
		elsif ['auto_verifies', 'query_reports', 'hvhs_data', 'logs'].include?(controller_name)
			'verification_platform'
		elsif ['view_summary', 'provider_sources'].include?(controller_name)
			'provider_app'
		elsif ['pages', 'systems'].include?(controller_name)
			'client_portal'
		elsif ['office_managers'].include?(controller_name)
			'office_manager'
		elsif	['roles', 'users'].include?(controller_name)
			'settings'
		elsif ['manage_clients'].include?(controller_name)
				'manage_clients'
		elsif ['enrollment_clients'].include?(controller_name)
			'enrollment_clients'
		else
			controller_name
		end
	end

	def redirect_to_filtered_page page
		return if page == 'overview'
		case page
		when 'verification_platform', 'enrollment_clients', 'office_manager', 'settings', 'manage_clients', 'manage_practitioners', 'work_ticklers'
			redirect_to controller: page, action: 'index'
		when 'client_portal', 'plm_sales_tool', 'smart_contract'
				redirect_to send("#{page}_path")
	 when 'enrollment_tracking'
			redirect_to overview_providers_path
		when 'provider_app'
			redirect_to custom_provider_source_path
		else
		 render 'shared/access_denied' and return
		end
	end

	def current_role
		return nil unless current_user.present?

		page = translate_page
		role = current_user&.roles.find_by(page: page)
	rescue
		nil
	end

	def find_role page
		current_user&.roles.find_by(page: page) rescue	nil
	end

	def active_menu cname, aname = nil
		if aname.present?
			cname.split(',').include?(controller_name) && aname.split(',').include?(action_name) ? 'ph-active fw-semibold' : ''
		else
			cname.split(',').include?(controller_name) ? 'ph-active fw-semibold' : ''
		end
	end

	def active_manage_tool_sub_menu cname, aname = nil
		if aname.present?
			cname.split(',').include?(controller_name) && aname.split(',').include?(action_name) ? 'active' : ''
		else
			cname.split(',').include?(controller_name) ? 'active' : ''
		end
	end

	def current_provider_source
		ProviderSource.find_or_create_by(current_provider_source: true)
	end

	# def active_menu_old cname, aname
	# 	cname == controller_name && aname.split(',').include?(action_name) ? 'ph-active' : ''
	# end

	def active_submenu cname, aname = ''
		(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? '' : 'd-none'
	end

	def chevron_active cname, aname = ''
		(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'rotate-chev' : ''
	end

	def active_submenu_link cname, aname = ''
		cname == controller_name && aname.split(',').include?(action_name) ? 'link_active fw-semibold' : ''
	end

	def enrollment_nav_active cname, aname = nil
		if aname.present?
			(cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		else
			cname.split(',').include?(controller_name) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey'
		end
	end

  def encompass_nav_active cname, aname = nil
    if aname.present?
      (cname.split(',').include?(controller_name) && aname.split(',').include?(action_name)) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey border-0'
    else
      cname.split(',').include?(controller_name) ? 'btn-primary fw-semibold' : 'btn-secondary text-black bg-alt-grey border-0'
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

  def current_logo
   @current_logo ||= if current_setting.qualifacts?
      'qualifacts-logo.svg'
    else
      'plm-logo-3.png'
    end
  end

  def current_logo_sm
    @current_logo_sm ||= if current_setting.qualifacts?
      'qualifacts-logo-sm.svg'
    else
      'plm-logo-square.png'
    end
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
		providers.map{|p| ["#{p.provider_name}", p.id]}
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

	def specialties
	 @specialties	||= Specialty.all
	end

  def groups
    @groups ||= EnrollmentGroup.all
  end

	def group_dcos
    @group_dcos ||= GroupDco.all
  end

	def training_types
    @training_types = TrainingType.all
  end

	def training_types
    @training_types = TrainingType.all
  end

	def privilege_statuses
    @privilege_status ||= PrivilegeStatus.all
  end

	def visa_types
    @visa_types ||= VisaType.all
  end

	def languages
    @languages ||= Language.all
  end

	def enrollment_payers
		@enrollment_payers ||= EnrollmentPayer.all
	end
	# memoization

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

  # not sure why but for some reason this has different options
  def enrollment_status
    [
			['Application Not Submitted','application-not-submitted'],
      ['Application Submitted','application-submitted'],
      ['Processing','processing'],
      ['Approved','approved'],
      ['Denied','denied'],
      ['Terminated','terminated'],
			['Not Eligible','not-eligible']
    ]
  end

  def days_options
    [
      ['Sunday','S'],
      ['Monday', 'M'],
      ['Tuesday', 'T'],
      ['Wednesday', 'W'],
      ['Thursday', 'Th'],
      ['Friday', 'F'],
      ['Saturday', 'S']
    ]
  end

  def titles
    [
      ["Dr.", "Dr."],
      ["Madam", "Madam"],
      ["Maj.","Maj."],
      ["Miss", "Miss"],
      ["Mr.", "Mr."],
      ["Mrs.","Mrs."],
      ["Ms.","Ms."],
      ["Sir","Sir"]
    ]
  end

	def toggle_hide data_key
			ProviderSourceData.find_by(data_key: data_key)&.hide_class
	end

  def enrollment_group_options
    EnrollmentGroup.all.pluck(:group_name, :id)
  end

  def enrollment_payer
    [
      ['Medicaid','medicaid'],
      ['Medicare','medicare'],
      ['Molina','molina'],
      ['Mclaren','mclaren'],
      ['Meridian','meridian'],
      ['Aetna','aetna'],
      ['Amerihealth','amerihealth'],
      ['Priority Health','priority_health']
    ]
  end

  def enrollment_provider_options
    EnrollmentProvider.all.pluck(:name, :id)
  end

  def encompass_active_classes
    'active btn-primary  fw-semibold'
  end

  def encompass_idle_classes
    'bg-alt-grey text-black'
  end

  def countries
     Country.all_translated
  end

	def page_entries_info(collection, options = {})
			entry_name = options[:entry_name] || (collection.empty?? 'item' :
							collection.first.class.name.split('::').last.titleize)
			if collection.total_pages < 2
					case collection.size
					when 0; "No #{entry_name.pluralize} found"
					else; "Displaying all #{entry_name.pluralize}"
					end
			else
					%{Displaying %d - %d of %d #{entry_name.pluralize}} % [
							collection.offset + 1,
							collection.offset + collection.length,
							collection.total_entries
					]
			end
	end

  def civil_statuses
    [
      ['Single','single'],
      ['Married', 'married'],
      ['Widowed','widowed']
    ]
  end

		def provider_statuses
			[
        ['Pending','pending'],
				['Active','active'],
				['Inactive','inactive']
		]
		end

  def time_line_class(status)
    cls = "danger"
    if status == 'done'
      cls = 'success'
    end
    cls
  end

  def time_line_icon(status)
    icon = "bi-clock-fill"
    if status == 'done'
      icon = 'bi-check-circle-fill'
    end
    icon
  end

  def provider_uploaded_files_titles
    [
      'State License Copy',
      'DEA Copy', 'W9 Form',
      'Certificate of Insurance',
      'Driver’s License',
      'License Registered State',
      'CAQH App Copy','Curriculum Vitae (CV)',
      'Telehealth License Copy'
    ]
  end

	def form_control_classes(options = {})
  classes = ['form-control', 'border']
  classes << 'border-danger' if options[:danger]
  classes << 'border-dark' unless options[:danger]
  classes.join(' ')
	end

	def form_select_classes(options = {})
			classes = ['form-select', 'border']
			classes << 'border-danger' if options[:danger]
			classes << 'border-dark' unless options[:danger]
			classes.join(' ')
	end

	def payor_submission_types
		[
			['Paper','paper'],
			['Roster','roster'],
			['Portal','portal']
		]
	end

	def medicare_tricare_parties
		[
			['Yes-Medicare','yes-medicare'],
			['Yes-Tricare','yes-tricare'],
			['Yes-Medicare and Tricare','yes-medicare-and-tricare'],
			['No','no']
		]
	end

	def hide_show_card card_name
		current_user&.is_card_open?(card_name) ? '' : 'display: none;' rescue ''
	end
end
