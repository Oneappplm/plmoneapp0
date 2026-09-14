class PracticeLocation < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

  has_many :provider_sources
  has_many :group_engage_providers

	def address = "#{address1} #{address2}"


  validates :location, :address1, :city, :state_id, :zip_code, :phone_number, :email, :group_tax_number, presence: true  
  validates :email, presence: true, uniqueness: true, 
                    format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "must be a valid email format" }

  LOCATION_SERVICES = [
    "Acupuncture - SUD",
    "Age Appropriate Immunizations",
    "Allergy Injections",
    "Allergy Skin Testing",
    "Assertive Community Treatment (ACT)*",
    "Assessments",
    "Asthma Treatment",
    "Autism Services/Applied Behavioral Analysis",
    "Behavioral",
    "Behavioral Health Treatment Plan",
    "Cardiac Stress Tests",
    "Club House/Psychosocial Rehabilitation*",
    "Community Transition (Waiver for Children-SED only)",
    "Crisis Residential Services*",
    "Day Program Sites*",
    "Drawing Blood",
    "Drop-In Center Programs*",
    "Family Training",
    "Fiscal Intermediary",
    "Foster Care, Therapeutic (SEDW only) Health Services",
    "Home-Based Services *",
    "Inpatient Mental Health",
    "Intensive Crisis Stabilization*",
    "IV Hydration/Treatment",
    "Medication Administration",
    "Medication Review",
    "Mental Health Individual, Family, and Group Therapy - Adult",
    "Mental Health Individual, Family, and Group Therapy - Child",
    "Minor Lacerations",
    "Nursing Facility Mental Health Monitoring",
    "Occupational Therapy",
    "Osteopathic Manipulation",
    "Partial Hospitalization",
    "Pediatric Services",
    "Peer-Directed and Operated Support Services",
    "Personal Care in Licensed Specialized Residential Setting",
    "Physical Therapy",
    "Private Duty Nursing",
    "Pulmonary Function Testing",
    "Radiology",
    "Respite Care Services",
    "Respite Care Services, not in-home",
    "Routine Gynecology (Pelvic/Pap)",
    "Specialty Services (Children's Waiver & Waiver for Children with SED only)",
    "Speech/Language Therapy",
    "SUD Individual Assessment",
    "SUD Intensive Outpatient",
    "SUD Methadone",
    "SUD Outpatient Care",
    "SUD Residential Services",
    "SUD-Acute Detoxification",
    "Supports Coordination",
    "Targeted Case Management",
    "Therapy (Mental Health) Child & Adult, Individual, Family Group",
    "Transportation",
    "Tympanometry/Audiometry Screening",
    "Women's Healthcare",
    "Wraparound Services*"  
  ]

  PATIENCE_ACCEPTANCE1 = [
    "New Patients",
    "All New Patients",
    "Existing Patients with a Change of Payor",
    "New Patients from Physician Referral Only",
    "New Medicare Patients",
    "New Medicaid Patients",
    "New Patients Varies by Health Plan",
    "Medicare Patients",
    "Medicaid Patients",
    "New BWC (Bureau of Workers’ Compensation) Patients",
    "New Patients in the Future",
    "Workers’ Compensation Patients",
    "None"
  ]

  ADA_ACCESSIBILITY = [
   "Handicapped Building Access",
   "Handicapped Parking Access",
   "Handicapped Restroom Access",
   "Other Handicapped Access"
  ]

  DISABLED_OTHER_SERVICE = [
    "American Sign Language (ASL)",
    "Mental/Physical Impairment Services",
    "TDD Service (Telecommunications Device for the Deaf)",
    "Text Telephone (TTY)",
    "Other Disability Service"
  ]

  PUBLIC_TRANSPORTATION = [
    "Other Transportation",
    "Bus Transportation",
    "Light Rail Transportation",
    "Regional Train Transportation",
    "Subway Transportation"
  ]

  LABORATORY_SERVICES = [
    "AAFP - America Academy of Family Physicians",
    "CAP - College of American Pathologists.",
    "CLIA - Clinical Laboratory Improvement Amendments",
    "COLA - Commission on Office Laboratory Accreditation",
    "MLE - Medical Laboratory Evaluation"
  ]

end
