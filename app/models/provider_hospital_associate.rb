class ProviderHospitalAssociate < ApplicationRecord
  self.primary_key = :provider_hospital_associate_id

  belongs_to :provider_attest
  belongs_to :provider_hospital_privilege, foreign_key: :provider_hospital_id

  validates :provider_attest, presence: true
end
