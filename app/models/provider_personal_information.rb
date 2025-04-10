class ProviderPersonalInformation < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID']

  belongs_to :provider_attest

  has_many :practice_informations, through: :provider_attest
  has_many :provider_educations, through: :provider_attest
  has_many :provider_deas, through: :provider_attest
  has_many :provider_cds, through: :provider_attest
  has_many :provider_insurance_coverages, through: :provider_attest
  has_many :practice_associates, through: :provider_attest
  has_many :provider_medicares, foreign_key: :provider_attest_id, primary_key: :provider_attest_id
  has_many :provider_medicaids, foreign_key: :provider_attest_id, primary_key: :provider_attest_id, dependent: :destroy
  has_many :provider_militaries, foreign_key: :provider_attest_id, primary_key: :provider_attest_id, dependent: :destroy
  has_many :provider_work_histories, through: :provider_attest
  has_many :provider_medical_licenses, through: :provider_attest
  has_many :provider_specialties, through: :provider_attest
  has_many :provider_deas, through: :provider_attest
  has_many :provider_personal_uploaded_docs, class_name: 'ProviderPersonalUploadedDoc'

  has_many :provider_personal_information_sam_records
  has_many :provider_personal_information_reinstatements
  has_many :provider_personal_information_comments
  has_many :provider_personal_information_app_trackings
  has_many :rva_informations

  has_one :provider_personal_information_credentialing_contact
  has_one :provider_personal_information_confidential_contact

  has_many :provider_personal_attempts, through: :provider_attest

  has_many :provider_personal_docs_uploaded_documents, class_name: 'ProviderPersonalDocsUpload', through: :provider_attest

  has_one :provider_personal_docs_receive, through: :provider_attest

  validates :provider_attest_id, presence: true

  accepts_nested_attributes_for :provider_personal_information_credentialing_contact, allow_destroy: false, update_only: true
  accepts_nested_attributes_for :provider_personal_information_confidential_contact, allow_destroy: false, update_only: true


  def fullname = "#{last_name}, #{first_name} #{middle_name}"
  def correspondence_address_type_correspondence_address_type_descripion = correspondence_address_type_correspondence_address_type_descrip

  before_validation :set_provider_attest
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def self.ransackable_attributes(auth_object = nil)
    ["active_military_flag", "answering_service_phone_number", "application_method", "application_type", "attest_date", "availability", "birth_city", "birth_country_country_name", "birth_date", "birth_state", "caqh_provider_attest_id", "caqh_provider_id", "cds_flag", "cell_phone_number", "citizenship_country_country_name", "citizenship_status", "client_batch_date", "client_batch_id", "client_batch_name", "correspondence_address_type_correspondence_address_type_descrip", "created_at", "cred_status", "credentials_committee_date", "date_of_birth", "dea_flag", "ecfmg_expiration_date", "ecfmg_flag", "ecfmg_issue_date", "ecfmg_number", "email_address", "emergency_contact_first_name", "emergency_contact_last_name", "emergency_contact_middle_name", "emergency_contact_phone", "ethnicity_description", "federal_employee_id", "fellowship_training_flag", "first_name", "gender", "gender_gender_description", "graduate_type_graduate_type_description", "hospital_admitting_arrangements", "hospital_based_flag", "hospital_privilege_flag", "id", "last_name", "last_recredential_date", "marital_status_marital_status_description", "market", "medicaid_provider_flag", "medicare_provider_flag", "middle_name", "next_recredential_date", "nid", "nid_country_country_name", "no_malpractice_claims_flag", "npi", "npi_flag", "npi_verification_status", "other_correspondence_address", "other_graduate_education_flag", "other_name_flag", "other_specialty_flag", "pager_beeper_digital_flag", "pager_beeper_number", "plan_provider_id", "practitioner_type", "primary_practice_state", "provider_attest_id", "provider_type_provider_type_abbreviation", "secondary_specialty_flag", "show_on_tickler", "spouse_first_name", "spouse_last_name", "spouse_middle_name", "ssn", "state_residence_date", "status", "suffix", "tax_id", "teaching_appointment_flag", "updated_at", "upin", "upin_flag", "us_eligible_flag", "verification_status", "visa_expiration_date", "visa_issue_date", "visa_number", "visa_status", "visa_type", "work_history_gap_flag", "work_permit_status"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["practice_associates", "practice_informations", "provider_attest", "provider_cds", "provider_deas", "provider_educations", "provider_insurance_coverages", "provider_medicaids", "provider_medical_licenses", "provider_medicares", "provider_militaries", "provider_personal_attempts", "provider_personal_docs_receive", "provider_personal_docs_uploaded_documents", "provider_personal_information_app_trackings", "provider_personal_information_comments", "provider_personal_information_confidential_contact", "provider_personal_information_credentialing_contact", "provider_personal_information_reinstatements", "provider_personal_information_sam_records", "provider_personal_uploaded_docs", "provider_specialties", "provider_work_histories", "rva_informations"]
  end
end
