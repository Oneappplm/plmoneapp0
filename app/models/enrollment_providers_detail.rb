class EnrollmentProvidersDetail < ApplicationRecord
  belongs_to :enrollment_provider

  scope :submitted, -> { where(enrollment_status: 'application-submitted') }
  scope :submitted, -> { where(enrollment_status: 'application-not-submitted') }
  scope :processing, -> { where(enrollment_status: 'processing') }
  scope :approved, -> { where(enrollment_status: 'approved') }
  scope :denied, -> { where(enrollment_status: 'denied') }
  scope :terminated, -> { where(enrollment_status: 'terminated') }
end 