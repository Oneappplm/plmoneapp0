class EnrollGroupsDetail < ApplicationRecord
  belongs_to :enroll_group
  # has_secure_password
  before_create :hash_password

  has_many :questions, class_name: 'EnrollGroupsDetailsQuestion', dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true

  mount_uploader :upload_payor_file, DocumentUploader

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  scope :submitted, -> { where(enrollment_status: 'application-submitted') }
  scope :not_submitted, -> { where(enrollment_status: 'application-not-submitted') }
  scope :processing, -> { where(enrollment_status: 'processing') }
  scope :approved, -> { where(enrollment_status: 'approved') }
  scope :denied, -> { where(enrollment_status: 'denied') }
  scope :terminated, -> { where(enrollment_status: 'terminated') }
  scope :not_eligible, -> { where(enrollment_status: 'not_eligible') }

  scope :aetna, -> {where(enrollment_payer: 'aetna')}
  scope :amerihealth, -> {where(enrollment_payer: 'amerihealth')}
  scope :medicare, -> {where(enrollment_payer: 'medicare')}
  scope :mclaren, -> {where(enrollment_payer: 'mclaren')}
  scope :molina, -> {where(enrollment_payer: 'molina')}
  scope :meridian, -> {where(enrollment_payer: 'meridian')}
  scope :priority_health, -> {where(enrollment_payer: 'priority_health')}
  scope :medicaid, -> {where(enrollment_payer: 'medicaid')}

  private

  # not sure when this will be used but had to encrypt password nonetheless
  def hash_password
    self.password_digest = BCrypt::Password.create(password)
  end
end