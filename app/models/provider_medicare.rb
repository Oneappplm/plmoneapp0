class ProviderMedicare < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicareID']

  belongs_to :provider_attest, foreign_key: :provider_attest_id
end