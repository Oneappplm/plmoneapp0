class ProviderEducationAssociate < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderEducationAssociateID','ProviderEducationID']

  belongs_to :provider_attest
  belongs_to :provider_education

  validates :provider_attest_id, presence: true
  validates :provider_education_id, presence: true

  before_validation :set_provider_attest
  before_validation :set_provider_education
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def set_provider_education
    self.provider_education = ProviderEducation.where(caqh_provider_education_id: self.caqh_provider_education_id).last
  end
end
