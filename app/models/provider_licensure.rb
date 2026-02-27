class ProviderLicensure < ApplicationRecord
  
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderEducationID']
 
  LICENSE_TYPE = [
    "AC",
    "ACU",
    "ADC",
    "AHP",
    "ANP",
    "APN",
    "ARNP",
    "AUD",
    "BCBA",
    "BCO",
    "BT",
    "C",
    "CCDC",
    "CDA",
    "CLC",
    "CLD",
    "CNA",
    "CNIM",
    "CNM",
    "CNP",
    "CNS",
    "COMT",
    "COT",
    "CP",
    "CRNA",
    "CRNP",
    "CRT",
    "CSP",
    "CST",
    "CSW",
    "DA",
    "DC",
    "DDS",
    "DDS, MD",
    "DMD",
    "DO",
    "DPM",
    "DT",
    "EdD",
    "EMT",
    "EPT",
    "FAC",
    "Facility",
    "FNP",
    "HAD",
    "Hospital",
    "LAC",
    "LADC ",
    "LALDC",
    "LCPC",
    "LCSW",
    "LEP",
    "LIMHP",
    "LISW",
    "LMFT",
    "LMT",
    "LN",
    "LP",
    "LPC",
    "LPN",
    "LSA",
    "LSW",
    "LVN",
    "MA",
    "MBBS",
    "MD",
    "MFCC",
    "MFCC/MFT",
    "MFT",
    "MH",
    "MHC",
    "MHP",
    "MPT",
    "MRT",
    "MS",
    "MSc",
    "MSSW",
    "MSW",
    "MT",
    "MW",
    "NC",
    "ND",
    "NEU",
    "NMF",
    "NMW",
    "NP",
    "NPF",
    "OD",
    "OPT",
    "OrthoT",
    "OT",
    "Other",
    "OTR",
    "PA",
    "PAA",
    "PAC",
    "PAO",
    "Paramedic",
    "PC",
    "PCC",
    "PHA",
    "Pharmacy",
    "PharmD",
    "PharmT",
    "PhD",
    "PHN",
    "PsyD",
    "PT",
    "PTA",
    "RCP",
    "RD",
    "RDA",
    "RDMS",
    "REPT",
    "RMA",
    "RN",
    "RNFA",
    "RPSGT",
    "RPT",
    "RRT",
    "RT",
    "SLD",
    "SLP",
    "SP",
    "WHCNP,"
  ]

  LICENSE_PERSON_TYPE = [
    "Resident",
    "Intern",
    "Fellow"
  ]

  belongs_to :provider_attest
  belongs_to :state, optional: true

  has_many :rva_informations, dependent: :destroy  
  has_many :provider_supervisings, dependent: :destroy, class_name: 'ProviderSupervising'

  accepts_nested_attributes_for :provider_supervisings, allow_destroy: true, reject_if: :all_blank
  
  validates :provider_attest_id, presence: true
  
  scope :shown_on_tickler, -> { where(show_on_tickler: ['Yes', true, nil]) }
  scope :not_skipped_rva, -> { where(audit_status: ['SkipRVA', "Quality Audited",  nil])}
  scope :expired_strict,   -> { where('license_expiration_date < ?', Date.current) }
  scope :expiring_30_days, -> { where(license_expiration_date: Date.current..30.days.from_now) }
  
  scope :active,           -> { where('license_expiration_date >= ?', Date.current) }

  scope :expired_and_tickler,  -> { expired_strict.shown_on_tickler.not_skipped_rva }
  scope :expiring_and_tickler, -> { expiring_30_days.shown_on_tickler.not_skipped_rva }

  before_validation :set_provider_attest, if: -> { caqh_provider_attest_id.present? }
  
  after_initialize :set_defaults

  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end

  private

  def set_defaults
    self.show_on_tickler ||= 'Yes'
  end

  def set_provider_attest
    match = ProviderAttest.find_by(caqh_provider_attest_id: caqh_provider_attest_id)
    self.provider_attest ||= match
  end
end
