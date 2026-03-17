class ProviderInsuranceCoverage < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID', 'ProviderInsuranceID']

  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  scope :shown_on_tickler, -> { where(show_on_tickler: ['Yes', true, nil]) }
  scope :not_skipped_rva, -> { where(audit_status: ['SkipRVA', "Quality Audited",  nil])}
  scope :expired_strict,   -> { where('end_date < ?', Date.current) }
  scope :expiring_30_days, -> { where(end_date: Date.current..30.days.from_now) }
  
  scope :active,           -> { where('end_date >= ?', Date.current) }

  scope :expired_and_tickler,  -> { expired_strict.shown_on_tickler.not_skipped_rva }
  scope :expiring_and_tickler, -> { expiring_30_days.shown_on_tickler.not_skipped_rva }

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
