class ProviderDea < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDEAID']
  serialize :schedules_held, Array

  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  scope :expired_strict, -> {
    where("expiration_date < ?", Date.current)
  }

  scope :active, -> {
    where("expiration_date >= ?", Date.current)
  }

  scope :missing_expiration, -> {
    where(expiration_date: nil)
  }


  before_validation :set_provider_attest
  private

  def set_provider_attest
    if caqh_provider_attest_id.present?
      self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
    end
  
    unless self.provider_attest
      errors.add(:provider_attest, "must be associated with a valid ProviderAttest")
    end
  end  
end
