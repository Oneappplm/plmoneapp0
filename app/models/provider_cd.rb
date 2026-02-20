class ProviderCd < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCDSID']

  belongs_to :provider_attest

  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  scope :shown_on_tickler, -> { where(show_on_tickler: ['Yes', true, nil]) }
  scope :expired_strict,   -> { where('expiration_date < ?', Date.current) }
  scope :active,           -> { where('expiration_date >= ?', Date.current) }

  scope :expired_and_tickler,  -> { expired_strict.shown_on_tickler }
  scope :expiring_and_tickler, -> { active.shown_on_tickler }

  before_validation :set_provider_attest

  after_initialize :set_defaults

  private
  
  def set_defaults
    self.show_on_tickler ||= 'Yes'
  end

  def set_provider_attest
    return if provider_attest_id.present?
    self.provider_attest = ProviderAttest.find_by(caqh_provider_attest_id: caqh_provider_attest_id)
  end
end

