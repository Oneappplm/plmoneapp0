module UserCommon
  extend ActiveSupport::Concern

  included do
    has_many :roles, class_name: "RoleBasedAccess", foreign_key: "role", primary_key: "user_role"
    has_many :notifications, as: :recipient
    has_many :sidebar_preferences, class_name: "UserSidebarPreference"
    has_many :users_enrollment_groups
    has_many :enrollment_groups, through: :users_enrollment_groups
  end

  class_methods do
    def create_admin
      Admin.create(
        email: 'admin@plmhealthoneapp.com',
        password: 'plmadmin123!',
        user_role: 'administrator',
        first_name: 'Admin',
        last_name: 'PLM',
      )
    end
  end

  def role = user_role&.titleize

  def full_name
    "#{self.first_name} #{middle_name} #{self.last_name}"
  end

  def name_initials
    if self.first_name && self.last_name
      "#{self.first_name.first}#{self.last_name.first}".upcase
    else
      "#{self.email.first}".upcase
    end
  end

  def default_page
    if roles.present?
      roles.where(page: PARENT_MENUS, can_read: true).take&.page || 'access_denied'
    else
      super_administrator? ? 'role_based_accesses' : 'access_denied'
    end
  end

  def landing_page
    parent_menu = default_page
    submenu = 'index'
    active_menus = roles.where(can_read: true).pluck(:page)
    SUB_MENUS[parent_menu.to_sym].each do |menu|
      if active_menus.include?(menu)
        submenu = menu
        break
      end
    end

    [parent_menu, submenu]
  end

  def current_role
    role.to_role
  end

  def allowed_roles
    excluded_roles = find_excluded_roles

    Role.all.map do |role|
      slug = role.name.parameterize(separator: "_")
      next if excluded_roles.include?(slug)

      [role.name, slug]
    end.compact
  end

  def find_excluded_roles
    # case user_role
    #   when 'administrator'
    #     ['super_administrator', 'encoder', 'test_user' ]
    #     # ['super_administrator','encoder','calls_agent','agent', 'test_user' ,'viewer']
    #   else
    #     ['encoder', 'test_user']
    #     # ['encoder','calls_agent','agent', 'test_user', 'viewer']
    # end
    ['administrator', 'super_administrator', 'encoder', 'test_user' ]
  end

  def role = user_role&.titleize
  def provider? = role == "Provider"

  def can_access? page = nil
    return true if is_a?(Admin) #Admins have full access to all pages by default

    # role-based access v2 is now attached to current_user instead of application helpers
    return false unless page.present?

    # to_role is monkey patch from String class in initializers/string.rb
    # force to return false instead of nil if role is not found
    roles.find_by(page: page.to_role)&.can_read || false
  end

  def restricted? page
    !can_access?(page)
  end

  def provider = Provider.find_by_id(accessible_provider)

  def not_allowed_to_view?(role = nil)
    find_excluded_roles.include?(role)
  end

  # temporarily commented to cater only using temporary password
  # def password_match
  #   errors.add(:password_confirmation, "must match the password") unless temporary_password == password_confirmation
  # end

  def from_source_enrollment?
    from_source.present? && from_source == 'enrollment'
  end

  def password_required?
    super && new_record?
  end

  def is_card_open?(collapse_name)
    self.sidebar_preferences.find_by(collapse_name: collapse_name)&.is_open rescue true
  end

  def generate_api_token
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless User.exists?(api_token: random_token)
    end
  end

  def set_temporary_password_as_password
    if temporary_password_changed?
      self.password = temporary_password
    end
  end

  def default_page_old
    return 'enrollment_clients' if is_provider_account?
    return 'overview' if roles.find_by(page: 'overview')&.can_read

    pages = []
    roles.each do |role|
      next if !role.can_read
      pages << role.page
    end

    if Setting.take.qualifacts? && pages.include?('enrollment_tracking')
      'enrollment_tracking'
    else
      pages&.first
    end
  end

  def generate_otp_code_and_expiration
    self.otp_code = loop do
      random_otp_code= SecureRandom.hex(3)
      break random_otp_code unless User.exists?(otp_code: random_otp_code)
    end
    self.otp_token = loop do
      random_otp_token = SecureRandom.hex(3)
      break random_otp_token unless User.exists?(otp_token: random_otp_token)
    end
    self.otp_code_expires_at = Time.now + 5.minutes
    self.save
  end

  def expired_otp_code?
    return true if self.otp_code_expires_at.blank?

    self.otp_code_expires_at < Time.now
  end

  def reset_opt
    self.otp_code = nil
    self.otp_token = nil
    self.otp_code_expires_at = nil
    self.save
  end

  def valid_otp? otp_code
    self.otp_code == otp_code
  end

  def send_otp_code
    PlmMailer.with(email: self.email, otp_code: self.otp_code).send_otp_code_mail.deliver_now
  end

  def expired_logout_on_close?
    return false unless last_logout_on_close

    last_logout_on_close&.utc < 10.seconds.ago
  end

  def reset_logout_on_close
    update_columns(
      logout_on_close: false,
      last_logout_on_close: nil
    )
  end

  def provider_source_lookup
    if provider? && group_engage_provider.present? && group_engage_provider.provider_source.present?
      group_engage_provider.provider_source
    else
      ProviderSource.find_or_create_by(current_provider_source: true, created_by_user: self.id)
    end
  end

  def send_invite_and_reset_password_instructions params = {}
    PlmMailer.with(user: self, token: generate_password_token, params: params).send_invite_and_reset_password_instructions.deliver_now
  end

  def generate_password_token
    token, enc = Devise.token_generator.generate(User, :reset_password_token)
    update_columns(reset_password_token: enc, reset_password_sent_at: Time.now.utc)

    token
  end

  private

  def set_user_role
    self.user_role = hidden_role if hidden_role.present?
  end

  def set_sidebar_preferences
    sidebar_cards = ['enrollment_details', 'licenses', 'documents','group', 'practice_location', 'enrollments', 'enrollment_payer', 'dco_outreach' ,'schedules']

    sidebar_cards.each do |card|
      UserSidebarPreference.find_or_create_by(user_id: self.id, collapse_name: card)
    end
  end
end
