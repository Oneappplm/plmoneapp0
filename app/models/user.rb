class User < ApplicationRecord
  include PgSearch::Model
  include UserCommon
  include DynamicRolesInitializer
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable,
         :confirmable

		audited

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
    provider: 'Provider',
    # docsynch: 'DocSynch',
    # medversant_admin: 'Medversant Admin',
    # ncqagroup: 'NCQA Group',
    # npdgroup: 'NPD Group',
    # superuser: 'Superuser',
  }

  SECURITY_QUESTIONS = [
    "What is your mother's maiden name?",
    "What was your first pet's name?",
    "What is your favorite book?",
    "What was your childhood nickname?",
    "What is your favorite food?",
    "Where were you born?"
  ].freeze


  validates :first_name, presence: true,  on: :create
  validates :last_name, presence: true, on: :create
  # temporarily commented to cater only using temporary password
  # validate :password_match

  with_options :on => :create, if: :from_source_enrollment? do |user|
    # user.validates_presence_of :status
    user.validates_presence_of :password_confirmation
    user.validates_length_of :password, within: 6..40
    # user.validates_confirmation_of :password
  end

  before_save :set_temporary_password_as_password, :set_user_role
  before_create :generate_api_token
  after_create :set_sidebar_preferences

  scope :from_enrollment, -> { where(from_source: 'enrollment')}
  scope :not_admin, -> { where.not(user_role: ['super_administrator', 'administrator']) }
  scope :admins, -> { where(user_role: 'administrator') }
  scope :agents, -> { where(user_role: 'agent') }
  scope :directors, -> { where(user_role: 'director') }

  # Ex:- scope :active, -> {where(:active => true)}

  has_one :group_engage_provider, dependent: :destroy

  has_many :director_providers
  has_many :virtual_review_committees, through: :director_providers

  accepts_nested_attributes_for :users_enrollment_groups, allow_destroy: true, reject_if: :all_blank

  attr_accessor :email_cc, :email_subject, :email_message, :hidden_role

  class << self
    def from_omniauth(auth)
      return nil unless auth && auth['info']['email'].present?
      
      info = auth['extra']['raw_info']

      user = User.find_or_create_by(email: auth['info']['email']) do |user|
        user.provider = auth['provider']
        user.uid = auth['uid']
        user.first_name = info['given_name']
        user.last_name = info['family_name']
      end

      if user.persisted? && user.confirmed_at.nil?
        user.confirmed_at = Time.current
        user.save(validate: false)
      end

      user
    end

    def set_user_sidebar_preferences
      User.all.each do |user|
        sidebar_cards = ['enrollment_details', 'licenses', 'documents','group', 'practice_location', 'enrollments', 'enrollment_payer', 'dco_outreach' ,'schedules']
        sidebar_cards.each  do |card|
          UserSidebarPreference.find_or_create_by(user_id: user.id, collapse_name: card)
        end
      end
    end

    def find_by_token(token)
      User.find_by(api_token: token)
    end

    def admin
      find_by(user_role: 'administrator')
    end

    def superadmin
      find_by(user_role: 'super_administrator')
    end

    def agent
      find_by(user_role: 'agent')
    end

    def admin_staff
      find_by(user_role: 'admin_staff')
    end
  end
end
