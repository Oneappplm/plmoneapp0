class ProviderPersonalInformation < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}, #{provider_type_provider_type_abbreviation}"

  before_validation :set_provider_attest
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end

