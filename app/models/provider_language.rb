class ProviderLanguage < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_language_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderLanguageID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
