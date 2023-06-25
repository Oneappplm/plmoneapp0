class EnrollmentProvidersDetail < ApplicationRecord
  belongs_to :enrollment_provider

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
end