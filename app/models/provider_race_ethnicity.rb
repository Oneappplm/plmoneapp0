class ProviderRaceEthnicity < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_race_ethnicity_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderRaceEthnicityID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
