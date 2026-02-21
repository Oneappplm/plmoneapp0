class ProviderInsuranceCoverage < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID', 'ProviderInsuranceID']

  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  scope :shown_on_tickler, -> { where(show_on_tickler: [true, nil]) }
  scope :expired_strict,   -> { where('expiration_date < ?', Date.current) }
  scope :active,           -> { where('expiration_date >= ?', Date.current) }

  scope :expired_and_tickler,  -> { expired_strict.shown_on_tickler }
  scope :expiring_and_tickler, -> { active.shown_on_tickler }

  before_validation :set_provider_attest

  after_initialize :set_default_show_on_tickler

  private

  def set_default_show_on_tickler
    self.show_on_tickler ||= 'Yes'
  end

  def set_provider_attest
    return if caqh_provider_attest_id.blank?

    self.provider_attest = ProviderAttest.find_by(caqh_provider_attest_id: caqh_provider_attest_id)
    Rails.logger.info "ProviderAttest set to: #{self.provider_attest.inspect}"
  end
end
