class EnrollmentProvidersDetail < ApplicationRecord
  belongs_to :enrollment_provider
  mount_uploaders :upload_payor_file, DocumentUploader

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

  has_many :application_status_logs, class_name: 'EpdLog', dependent: :destroy

  after_save :create_application_status_log, if: :saved_change_to_enrollment_status?

  protected
  def create_application_status_log
    self.application_status_logs.create(status: self.enrollment_status)
  end
end