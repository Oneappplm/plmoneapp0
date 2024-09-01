class ProviderMedicaid < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicaidID']

  belongs_to :provider, optional: true
  belongs_to :provider_attest, foreign_key: :provider_attest_id
end