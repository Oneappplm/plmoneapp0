class ProviderDea < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDEAID']
  serialize :schedules_held, Array

  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  scope :expired_strict, -> { where("expiration_date < ?", Date.current) }
  
  scope :expiring_30_days, -> { where(expiration_date: Date.current..30.days.from_now) }

  scope :active, -> {where("expiration_date >= ?", Date.current)}

  scope :missing_expiration, -> {where(expiration_date: nil)}

  scope :shown_on_tickler, -> { where(show_on_tickler: ['Yes', nil]) }
  
  scope :expired_and_tickler, -> { expired_strict.shown_on_tickler }

  scope :expiring_and_tickler, -> {expiring_30_days.shown_on_tickler}

  before_validation :set_provider_attest

  after_initialize :set_defaults, if: :new_record?

  def latest_registration_rva_information(provider_personal_information_id = nil)
    scope = rva_informations.where(tab: "Registration")
    scope = scope.where(provider_personal_information_id: provider_personal_information_id) if provider_personal_information_id.present?
    scope.order(created_at: :desc).first
  end

  def latest_completed_dea_webcrawler_log(provider_personal_information_id = nil)
    scope = DeaWebcrawlerLog
              .joins(:rva_information)
              .where(rva_informations: { provider_dea_id: id, tab: "Registration" })
              .where(status: "completed")

    if provider_personal_information_id.present?
      scope = scope.where(rva_informations: { provider_personal_information_id: provider_personal_information_id })
    end

    scope.order(created_at: :desc).first
  end

  private

  def set_defaults
    self.show_on_tickler ||= 'Yes'
  end

  def set_provider_attest
    if caqh_provider_attest_id.present?
      self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
    end
  
    unless self.provider_attest
      errors.add(:provider_attest, "must be associated with a valid ProviderAttest")
    end
  end  
end
