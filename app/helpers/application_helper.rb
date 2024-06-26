
module ApplicationHelper
	include RolesHelper # this is the file that contains the role-based access methods

	def current_client_organization
		current_client_organization = ClientOrganization.take || ClientOrganization.new
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
		current_user.provider_source_lookup
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
			return current_setting.logo_file.url if current_setting.logo_file.present?

   @current_logo ||= if current_setting.qualifacts?
					asset_path('qualifacts-logo.svg')
    else
					asset_path('plm-logo-3.png')
    end
  end

  def current_logo_sm
			return current_setting.logo_file.url if current_setting.logo_file.present?

    @current_logo_sm ||= if current_setting.qualifacts?
						asset_path('qualifacts-logo-sm.svg')
    else
						asset_path('plm-logo-square.png')
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
		if current_user.can_access_all_groups? || current_user.super_administrator?
    	@groups ||= EnrollmentGroup.all
		else
			@groups ||= current_user.enrollment_groups
		end
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
	  	['Not Eligible','not-eligible'],
	  	['Revalidation','revalidation'],
		  ['Not Part of Contract','none-contract']

    ]
  end

	def provider_notification_services
		[
			['Practice/Provider Setups', 'provider_setup'],
			['Monthly Monitoring', 'monthly_monitoring'],
			['Facility Enrollments/Maintenance', 'facility_maintenance'],
			['Provider Enrollments/Maintenance', 'provider_maintenance'],
			['FBI Checks', 'fbi_checks'],
			['Hospital Org PSV', 'hospital_org']
		]
	end

	def group_notification_services
		[
			['Practice/Provider Setups', 'provider_setup'],
			['Monthly Monitoring', 'monthly_monitoring'],
			['Facility Enrollments/Maintenance', 'facility_maintenance'],
			['Provider Enrollments/Maintenance', 'provider_maintenance'],
			['FBI Checks', 'fbi_checks'],
			['Hospital Org PSV', 'hospital_org']
		]
	end



	def provider_generate_report_options
		[
			['Provider Monthly Submitted Enrollment','provider_submitted_enrollments'],
      ['Group Monthly Submitted Enrollment','group_submitted_enrollments'],
      ['Group Enrollment Detail Report','group_detail_report'],
      ['Termed Providers', 'termed_providers'],
			['New Profile Setup in OneApp', 'new_profile_setup_in_one_app'],
      ['Missing Items Report','missing_items_report'],
      ['License Report','license_report'],
      ['DEA','dea'],
      ['SAM(coming soon)','sam'],
			['CAQH','caqh'],
			['OIG(coming soon)','oig'],
			['Liability','liability'],
			['Group Revalidation(coming soon)','group_revalidation'],
			['Provider Enrollment Detail Report', 'provider_enrollment_details_report'],
			['Provider Revalidation Report', 'provider_revalidation_report'],
			['Active Providers Report', 'active_providers_report']
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

  def toggle_hide_current_provider_source data_key, current_provider_source
      ProviderSourceData.find_by(data_key: data_key, provider_source_id: current_provider_source.id)&.hide_class
  end

  def enrollment_group_options
		if current_user.can_access_all_groups? || current_user.super_administrator?
    	EnrollmentGroup.all.pluck(:group_name, :id)
		else
			current_user.enrollment_groups&.pluck(:group_name, :id)
		end
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
				['Active','active'],
				['Active/Not Enrolled','active-not-enrolled'],
				['Inactive/Termed','inactive-termed'],
				['Pending','pending'],
		]
		end

		def group_statuses
			[
				['Active','active'],
				['Active/Not Enrolled','active-not-enrolled'],
				['Inactive/Termed','inactive-termed'],
				['Pending','pending'],
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
      'Board Certification',
      'CAQH App Copy','Curriculum Vitae (CV)',
      'Telehealth License Copy',
      'Copy of Certificate'
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

	def search_select_classes(options = {})
    classes = ['search-select', 'state-search-select', 'form-control']
    classes << 'border-danger' if options[:danger]
    classes << 'border-dark' unless options[:danger]
    classes.join(' ')
  end

	#had to add this method to avoid conflict on other state dropdown
	def single_search_classes(options = {})
    classes = ['state-select', 'single-select', 'form-control']
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

	def flatforms
		[
			['Credible','credible'],
			['CareLogic','carelogic'],
			['Insync','insync']
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

	def application_status_count status
		if current_user.can_access_all_groups? || current_user.super_administrator?
			@enrollment_provider_details = EnrollmentProvidersDetail
		else
			@enrollment_provider_details = EnrollmentProvidersDetail.includes(enrollment_provider: :provider).where(provider: {enrollment_group_id: current_user.enrollment_groups.pluck(:id)})
		end
		case status
		when 'application-submitted'
			@enrollment_provider_details.submitted.count
		when 'application-not-submitted'
			@enrollment_provider_details.not_submitted.count
		when 'processing'
			@enrollment_provider_details.processing.count
		when 'approved'
			@enrollment_provider_details.approved.count
		when 'denied'
			@enrollment_provider_details.denied.count
		when 'terminated'
			@enrollment_provider_details.terminated.count
		when 'not-eligible'
			@enrollment_provider_details.not_eligible.count
		else
			0
		end
	end

  def enrollment_types
    [
      ['Add','add'],
      ['Initial','Initial'],
      ['Re-validation/Re-credentialing','recred'],
      ['Not part on contract','not_part_on_contract']
    ]
  end

  def get_enrollment_type(selected_enrollment_type)
    enrollment_types.each do |e|
      return e[0] if e[1] == selected_enrollment_type
    end
    selected_enrollment_type
  end

  def provider_all_required_fields
    [
      ['First Name', 'first_name'],
      ['Last Name', 'last_name'],
      ['SSN', 'ssn'],
      ['Date of birth', 'birth_date'],
      ['Birth City', 'birth_city'],
      ['Birth State', 'birth_state'],
      ['Address Line 1', 'address_line_1'],
      ['City', 'city'],
      ['State','state_id'],
      ['Zip Code', 'zip_code'],
      ['Practitioner Type', 'practitioner_type'],
      ['Taxonomy', 'taxonomy'],
      ['Specialty', 'specialty'],
      ['Group','enrollment_group_id'],
      ['State License Copy', 'state_license_copy_file'],
      ['DEA Copy', 'dea_copy_file'],
      ['W9 Form', 'w9_form_file' ],
      ['Certificate of Insurance', 'certificate_insurance_file'],
      ['Drivers License', 'drivers_license_file' ],
      ['License Registered State', 'board_certification_file' ],
      ['CAQH App Copy', 'caqh_app_copy_file' ],
      ['Curriculum Vitae (CV)', 'cv_file' ],
      ['Telehealth License Copy', 'telehealth_license_copy_file'],
      ['Copy of Certificate', 'school_certificate']
    ]
  end

  def month_options
    [
      ['January','January'],
      ['February','February'],
      ['March','March'],
      ['April','April'],
      ['May','May'],
      ['June','June'],
      ['July','July'],
      ['August','August'],
      ['September','September'],
      ['October','October'],
      ['November','November'],
      ['December','December'],
    ]
  end

	def format_number_for_leading_zeroes(value)
    return nil unless value.present?
    if value.is_a?(Array)
      if value.size > 1
        return value.collect { |i| i.to_s }.join(", ")
      else
        return value.collect { |i| '="' + "#{i.to_s}" + '"' }.join(", ")
      end
    else
      return '="' + "#{value.to_s}" + '"'
    end
  end

  def application_statuses
    [['Application Not Submitted','application-not-submitted'],['Application Submitted','application-submitted'],['Processing','processing'],['Approved','approved'],['Denied','denied'],['Terminated','terminated'],['Not Eligible','not-eligible'],['Revalidation','revalidation'],['Not Part of Contract','none-contract']]
  end

		def display_mdy value
			Time.zone.parse(value.to_s)&.strftime('%m/%d/%Y') rescue nil
		end

		def menu_links
			@menu_links ||= {
				overview: {
					controller:	'dashboard',
					action: 'dashboard'
				},
				dashboard: {
					data_access: {
						controller: 'pages',
						action: 'client_portal'
					},
					decision_point: {
						controller: 'pages',
						action: 'virtual_review_committee'
					}
				},
				provider_engage:	{
					controller: 'provider_app',
					action: 'provider_source'
				},
				group_engage: {
					manage_provider: {
						controller: 'office_managers',
						action: 'index'
					},
					manage_practice: {
						controller: 'office_managers',
						action: 'manage_practice_locations'
					}
				},
				enrollment_dashboard: {
					ed_dashboard: {
						controller: 'enrollment_clients',
						action: 'dashboard'
					},
					groups: {
						controller: 'enrollment_clients',
						action: 'groups'
					},
					provider_data: {
						controller: 'enrollment_clients',
						action: 'index'
					},
					reports: {
						controller: 'enrollment_clients',
						action: 'reports'
					},
					notifications: {
						controller: 'enrollment_clients',
						action: 'notifications'
					}
				},
				enrollment_tracking: {
					et_overview: {
						controller: 'providers',
						action: 'overview'
					},
					providers: {
						controller: 'providers',
						action: 'index'
					},
					enrollment: {
						controller: current_setting.qualifacts? ? 'client_provider_enrollments' : 'enrollment_providers',
						action: 'index'
					},
					groups: {
						controller: 'enrollments',
						action: 'groups'
					}
				},
				verification_platform: {
					client_home: {
						controller: 'verification_platform',
						action: 'index'
					},
					manage_client: {
						controller: 'manage_clients',
						action: 'index'
					},
					manage_practitioner: {
						controller: 'manage_practitioners',
						action: 'index'
					},
					manage_tools: {
						controller: 'manage_tools',
						action: 'manage_cme'
					},
					query_report: {
						controller: 'query_reports',
						action: 'index'
					},
					work_tickler: {
						controller: 'work_ticklers',
						action: 'index'
					},
					manage_db: {
						controller: 'hvhs_data',
						action: 'index'
					},
					autoverify: {
						controller: 'autoverifies',
						action: 'index'
					}
				},
				role_based_access: {
					users: {
						controller: 'users',
						action: 'index'
					},
					role_access: {
						controller: 'role_based_accesses',
						action: 'index'
					}
				}
			}
		end
end