class ProviderMedicalAssociation < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_medical_association_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicalAssociationID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
