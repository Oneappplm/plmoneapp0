class PracticeInformation < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeID']

  belongs_to :provider_attest
  has_many   :practice_accessibilities
  has_many   :practice_associates
  has_many   :practice_associate_other_questions
  has_many   :practice_associate_specialties
  has_many   :practice_business_arrangements
  has_many   :practice_certifications
  has_many   :practice_hours
  has_many   :practice_languages
  has_many   :practice_limitations
  has_many   :practice_other_addresses
  has_many   :practice_other_questions
  has_many   :practice_other_tax_ids
  has_many   :practice_patient_types
  has_many   :practice_phone_coverages
  has_many   :practice_services
  has_many   :practice_specialties
  has_many   :practice_tax_ids

  validates :provider_attest_id, presence: true

  def complete_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  before_validation :set_provider_attest

  private

  def set_provider_attest
    return if self.provider_attest_id.present?
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end
