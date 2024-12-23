class PracticeInformation < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeID']

  def get_state
    State.find_by(id: state)
  rescue
    nil
  end

  belongs_to :provider_attest
  has_many   :practice_accessibilities
  has_many   :practice_associates
  has_many   :practice_associate_other_questions
  has_many   :practice_associate_specialties
  has_many   :practice_business_arrangements
  has_many   :practice_certifications
  has_many   :practice_hours
  has_many   :practice_languages
  has_many   :practice_limitations
  has_many   :practice_other_addresses
  has_many   :practice_other_questions
  has_many   :practice_other_tax_ids
  has_many   :practice_patient_types
  has_many   :practice_phone_coverages
  has_many   :practice_services
  has_many   :practice_specialties
  has_many   :practice_tax_ids

  has_many :allied_health_practitioners, dependent: :destroy, class_name: "AlliedHealthPractitioner"
  has_many :personally_employed_practitioners, dependent: :destroy, class_name: "PersonallyEmployedPractitioner"
  has_many :licensed_members, dependent: :destroy, class_name: "LicensedMember"
  has_many :staff_spoken_foreign_languages, dependent: :destroy, class_name: "StaffSpokenForeignLanguage"
  has_many :provider_anesthesia_administrations, dependent: :destroy, class_name: "ProviderAnesthesiaAdministration"
  has_many :covering_practitioners, dependent: :destroy, class_name: "CoveringPractitioner"

  accepts_nested_attributes_for :allied_health_practitioners, allow_destroy: true, reject_if: :all_blank
  
  accepts_nested_attributes_for :personally_employed_practitioners, allow_destroy: true, reject_if: :all_blank
  
  accepts_nested_attributes_for :licensed_members, allow_destroy: true, reject_if: :all_blank
  
  accepts_nested_attributes_for :staff_spoken_foreign_languages, allow_destroy: true, reject_if: :all_blank
  
  accepts_nested_attributes_for :provider_anesthesia_administrations, allow_destroy: true, reject_if: :all_blank
  
  accepts_nested_attributes_for :covering_practitioners, allow_destroy: true, reject_if: :all_blank

  validates :provider_attest_id, presence: true

  def complete_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  COUNTRY = 
  ["Afghanistan",
    "Africa",
    "Albania",
    "Algeria",
    "Angola",
    "Antigua And Barbados",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Brazil",
    "Bulgaria",
    "Burkina Faso",
    "Burma",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Cayman Islands",
    "Central African",
    "Chad",
    "Chile",
    "China",
    "Christmas Island",
    "Colombia",
    "Congo",
    "Cook Islands",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Czech Republic",
    "Dem Rep of Cong",
    "Denmark",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "England",
    "Estonia",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hong Kong SAR",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Korea",
    "Kuwait",
    "Kyrgyzstan",
    "Lao",
    "Latvia",
    "Lebanon",
    "Liberia",
    "Libya",
    "Lithuania",
    "Macedonia",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Mali",
    "Malta",
    "Mauritius",
    "Mayotte",
    "Mexico",
    "Micronesia",
    "Moldova",
    "Mongolia",
    "Montserrat",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Nepal",
    "Netherlands",
    "Netherlands Ant",
    "New Guinea",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "Niue",
    "None",
    "Norway",
    "Oman",
    "Other",
    "Pakistan",
    "Panama",
    "Papua new Guine",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Puerto Rico",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Kitts And Nevis",
    "Saint Lucia",
    "Saint Vincent And the Grenadines",
    "Samoa",
    "Saudi Arabia",
    "Senegal",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovak Republic",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "SOUTH KOREA",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Suriname",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Togo",
    "Trinidad And Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "selected="">United States",
    "Uruguay",
    "Uzbekistan",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Yugoslavia",
    "Zambia",
    "Zimbabwe",]

  before_validation :set_provider_attest

  private

  def set_provider_attest
    return if self.provider_attest_id.present?
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end
