class ProviderHospitalPrivilege < ApplicationRecord
  self.primary_key = :provider_hospital_id

  belongs_to :provider_attest

  has_many :provider_hospital_associates, foreign_key: :provider_hospital_id

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest.id
  end
end
