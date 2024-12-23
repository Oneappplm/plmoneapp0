class ProviderSpecialty < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderSpecialtyID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
