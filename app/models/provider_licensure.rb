class ProviderLicensure < ApplicationRecord
  belongs_to :provider_attest

   PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderEducationID']
  
  has_many :provider_supervisings, dependent: :destroy, class_name: 'ProviderSupervising'
  accepts_nested_attributes_for :provider_supervisings, allow_destroy: true, reject_if: :all_blank
  
  validates :provider_attest_id, presence: true
  
  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end

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

  before_validation :set_provider_attest
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end
