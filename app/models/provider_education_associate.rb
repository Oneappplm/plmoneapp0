class ProviderEducationAssociate < ApplicationRecord
  self.primary_key = :provider_education_associate_id

  belongs_to :provider_attest
  belongs_to :provider_education

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_education.provider_attest_id
  end
end
