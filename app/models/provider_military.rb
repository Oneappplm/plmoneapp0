class ProviderMilitary < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_military_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMilitaryID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
