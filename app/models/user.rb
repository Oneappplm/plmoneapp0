class User < ApplicationRecord
  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

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


  validates :first_name, presence: true
  validates :last_name, presence: true

  with_options :on => :create, if: :from_source_enrollment? do |user|
    user.validates_presence_of :status
    user.validates_presence_of :password_confirmation
    user.validates_length_of :password, within: 6..40
    # user.validates_confirmation_of :password
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

  def role
    User.user_roles[user_type]
  end
end
