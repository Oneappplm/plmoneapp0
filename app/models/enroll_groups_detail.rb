class EnrollGroupsDetail < ApplicationRecord
  belongs_to :enroll_group
  # has_secure_password
  before_create :hash_password

  has_many :questions, class_name: 'EnrollGroupsDetailsQuestion', dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true

  mount_uploaders :upload_payor_file, DocumentUploader

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  scope :submitted, -> { where(application_status: 'application-submitted') }
  scope :not_submitted, -> { where(application_status: 'application-not-submitted') }
  scope :processing, -> { where(application_status: 'processing') }
  scope :approved, -> { where(application_status: 'approved') }
  scope :denied, -> { where(application_status: 'denied') }
  scope :terminated, -> { where(application_status: 'terminated') }
  scope :not_eligible, -> { where(application_status: 'not-eligible') }

  scope :aetna, -> {where(enrollment_payer: 'aetna')}
  scope :amerihealth, -> {where(enrollment_payer: 'amerihealth')}
  scope :medicare, -> {where(enrollment_payer: 'medicare')}
  scope :mclaren, -> {where(enrollment_payer: 'mclaren')}
  scope :molina, -> {where(enrollment_payer: 'molina')}
  scope :meridian, -> {where(enrollment_payer: 'meridian')}
  scope :priority_health, -> {where(enrollment_payer: 'priority_health')}
  scope :medicaid, -> {where(enrollment_payer: 'medicaid')}

  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end

  private

  # not sure when this will be used but had to encrypt password nonetheless
  def hash_password
    self.password_digest = BCrypt::Password.create(password)
  end
end