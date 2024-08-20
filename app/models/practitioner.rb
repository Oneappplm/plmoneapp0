class Practitioner < ApplicationRecord
  self.per_page = 20
  validates :first_name, presence:true
  validates :last_name, presence:true
  # validates :date_of_birth, presence: true
  # validates :social_security_number, presence: true

  def practitioner_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  belongs_to :client_organization, optional: true
  has_many :app_trackers
end
