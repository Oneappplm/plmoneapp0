class ProviderSpecialty < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderSpecialtyID']

  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true
end
