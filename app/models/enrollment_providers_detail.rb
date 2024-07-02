class EnrollmentProvidersDetail < ApplicationRecord
  belongs_to :enrollment_provider, optional: true
  mount_uploaders :upload_payor_file, DocumentUploader

  scope :submitted, -> { where(enrollment_status: 'application-submitted') }
  scope :not_submitted, -> { where(enrollment_status: 'application-not-submitted') }
  scope :processing, -> { where(enrollment_status: 'processing') }
  scope :approved, -> { where(enrollment_status: 'approved') }
  scope :denied, -> { where(enrollment_status: 'denied') }
  scope :terminated, -> { where(enrollment_status: 'terminated') }
  scope :not_eligible, -> { where(enrollment_status: 'not-eligible') }

  scope :aetna, -> {where(enrollment_payer: 'aetna')}
  scope :amerihealth, -> {where(enrollment_payer: 'amerihealth')}
  scope :medicare, -> {where(enrollment_payer: 'medicare')}
  scope :mclaren, -> {where(enrollment_payer: 'mclaren')}
  scope :molina, -> {where(enrollment_payer: 'molina')}
  scope :meridian, -> {where(enrollment_payer: 'meridian')}
  scope :priority_health, -> {where(enrollment_payer: 'priority_health')}
  scope :medicaid, -> {where(enrollment_payer: 'medicaid')}

  belongs_to :enrollment_provider
  has_many :application_status_logs, class_name: 'EpdLog', dependent: :destroy
  has_many :questions, class_name: 'EpdQuestion', dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: :all_blank

  after_save :create_application_status_log, if: :saved_change_to_enrollment_status?
  before_update :validate_start_date, :if => proc { start_date_changed? && start_date_was.present? }

  # add this for the follow-up date and reminder
  before_save :update_last_follow_up_date, if: :follow_up_date_changed?

  private

  def update_last_follow_up_date
    self.last_follow_up_date = self.follow_up_date_was if follow_up_date_changed? && follow_up_date.present?
  end

  protected
  def create_application_status_log
    self.application_status_logs.create(status: self.enrollment_status)
  end

  # return back to previous value if the new value is nil
  def validate_start_date
    update_columns(start_date: start_date_was) if start_date.nil?
  end
end