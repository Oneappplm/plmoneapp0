class User < ApplicationRecord
  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          } rescue nil

  enum user_type: {
    client_staff: 'Client Staff',
    client_admin: 'Client Admin',
    vrc_scheduler_staff: 'VRC Scheduler Staff',
    vrc_scheduler_director: 'VRC Scheduler Director',
    # docsynch: 'DocSynch',
    # medversant_admin: 'Medversant Admin',
    # ncqagroup: 'NCQA Group',
    # npdgroup: 'NPD Group',
    # superuser: 'Superuser',
  }

  enum user_roles: {
    administrator: 'Administrator',
    encoder: 'Encoder',
    calls_agent: 'Calls Agent'
  }


  validates :first_name, presence: true,  on: :create
  validates :last_name, presence: true, on: :create
  validate :password_match

  with_options :on => :create, if: :from_source_enrollment? do |user|
    # user.validates_presence_of :status
    user.validates_presence_of :password_confirmation
    user.validates_length_of :password, within: 6..40
    # user.validates_confirmation_of :password
  end

  after_create :set_sidebar_preferences
  before_create :generate_api_token

  scope :from_enrollment, -> { where(from_source: 'enrollment')}
  scope :not_admin, -> { where.not(user_role: 'administrator') }
  scope :admins, -> { where(user_role: 'administrator') }
  # Ex:- scope :active, -> {where(:active => true)}

  has_many :sidebar_preferences, class_name: "UserSidebarPreference"
  has_many :roles, class_name: "RoleBasedAccess", foreign_key: "role", primary_key: "user_role"

  class << self
    def set_user_sidebar_preferences
      User.all.each do |user|
        sidebar_cards = ['enrollment_details', 'licenses', 'documents','group', 'practice_location', 'enrollments', 'enrollment_payer', 'dco_outreach' ,'schedules']
        sidebar_cards.each  do |card|
           UserSidebarPreference.find_or_create_by(user_id: user.id, collapse_name: card)
        end
      end
    end

    def create_admin
      User.create(
        email: 'admin@plmhealthoneapp.com',
        password: 'plmadmin123!',
        user_role: 'administrator',
        first_name: 'Admin',
        last_name: 'PLM',
      )
    end

    def find_by_token(token)
      User.find_by(api_token: token)
    end

    def admin
      find_by(user_role: 'administrator')
    end
  end

  def role = user_role&.titleize

  def password_match
    errors.add(:password_confirmation, "must match the password") unless temporary_password == password_confirmation
  end

  def from_source_enrollment?
    from_source.present? && from_source == 'enrollment'
  end

  def password_required?
    super && new_record?
  end

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

  def is_card_open?(collapse_name)
    self.sidebar_preferences.find_by(collapse_name: collapse_name).is_open
    rescue
      true
  end

  def admin?
    user_role == 'administrator'
  end

  def generate_api_token
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless User.exists?(api_token: random_token)
    end
  end

  private

  def set_sidebar_preferences
    sidebar_cards = ['enrollment_details', 'licenses', 'documents','group', 'practice_location', 'enrollments', 'enrollment_payer', 'dco_outreach' ,'schedules']

    sidebar_cards.each do |card|
      UserSidebarPreference.find_or_create_by(user_id: self.id, collapse_name: card)
    end
  end
end
