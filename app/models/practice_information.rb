class PracticeInformation < ApplicationRecord
  self.primary_key = :provider_practice_id

  belongs_to :provider_attest
  has_many   :practice_accessibilities, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_associates, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_associate_other_questions, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_associate_specialties, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_business_arrangements, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_certifications, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_hours, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_languages, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_limitations, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_other_addresses, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_other_questions, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_other_tax_ids, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_patient_types, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_phone_coverages, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_services, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_specialties, foreign_key: [:provider_attest_id, :provider_practice_id]
  has_many   :practice_tax_ids, foreign_key: [:provider_attest_id, :provider_practice_id]

  validates :provider_attest_id, presence: true

  def complete_address
    "#{address}, #{city}, #{state} #{zip}"
  end
end
