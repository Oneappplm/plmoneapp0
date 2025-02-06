class ProviderEducation < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_education_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderEducationID']

  belongs_to :provider_attest

  has_many :provider_education_associates, foreign_key: [:provider_attest_id,:provider_education_id]

  validates :provider_attest_id, presence: true
end
