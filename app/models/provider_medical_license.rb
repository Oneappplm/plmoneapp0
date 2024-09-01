class ProviderMedicalLicense < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_license_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderLicenseID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
