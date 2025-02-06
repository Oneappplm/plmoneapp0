class ProviderEducationAssociate < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_education_associate_id,:provider_education_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderEducationAssociateID','ProviderEducationID']

  belongs_to :provider_attest
  belongs_to :provider_education, foreign_key: [:provider_attest_id,:provider_education_id]

  validates :provider_attest_id, presence: true
  validates :provider_education_id, presence: true
end
