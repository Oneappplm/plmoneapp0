class ProviderPersonalInformation < ApplicationRecord
  ransacker :name_or_attest_id do
    Arel.sql("
      CONCAT_WS(' ',
        COALESCE(first_name, ''),
        COALESCE(last_name, ''),
        COALESCE(caqh_provider_attest_id::text, ''),
        COALESCE(provider_attest_id::text, '')
      )
    ")
  end

   enum progress_status: {
    completed: 'completed',
    assigned: 'assigned',
    to_be_assigned: 'to_be_assigned'
  }


  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  has_many :director_providers
  has_many :users, through: :director_providers
  has_many :review_level_changes, dependent: :destroy

  has_many :practice_informations, through: :provider_attest
  has_many :practice_information_educations, through: :provider_attest
  has_many :provider_employments, through: :provider_attest
  has_many :provider_educations, through: :provider_attest
  has_many :certifications, through: :provider_attest
  has_many :provider_insurance_coverages, through: :provider_attest
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
  has_many :provider_personal_attempts
  has_many :provider_personal_docs_uploaded_documents, class_name: 'ProviderPersonalDocsUpload'
  has_many :provider_personal_uploaded_docs, class_name: 'ProviderPersonalUploadedDoc'
  has_one :provider_personal_docs_receive
  has_many :provider_licensures, through: :provider_attest
  has_many :provider_other_names, through: :provider_attest

  has_many :provider_personal_information_sam_records
  has_many :provider_personal_information_reinstatements
  has_many :provider_personal_information_comments
  has_many :provider_personal_information_app_trackings
  has_many :rva_informations, dependent: :destroy
  has_many :pdf_generation_queues, dependent: :destroy

  has_one :provider_personal_information_credentialing_contact
  has_one :provider_personal_information_confidential_contact
  has_one :provider_source, dependent: :destroy

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

  FIELD_MAP = {
    "first_name" => :first_name,
    "last_name" => :last_name,
    "middle_name" => :middle_name,
    "suffix" => :suffix,
    "state_of_practice" => :primary_practice_state,
    "primary-practioner-type" => :practitioner_type,
    "other_name" => :other_name_flag,
    "degree_titles" => :degree_titles,
    "email_address" => :email_address,
    "ps-gender" => :gender,
    "ps-dob" => :date_of_birth,
    "ps-citizenship" => :citizenship_status,
    "social-security-number" => :ssn,
    "reside-on-us" => :us_eligible_flag,
    "permanent-work-permit" => :work_permit_status,
    "visa-number" => :visa_number,
    "gi-visa-types" => :visa_type,
    "visa-status" => :visa_status,
    "visa-issue-date" => :visa_issue_date,
    "visa-expire-date" => :visa_expiration_date,
    "ethnicity" => :ethnicity_description,
    "marital-status" => :marital_status_marital_status_description,
    "emergency-first-name" => :emergency_contact_first_name,
    "emergency-middle-name" => :emergency_contact_middle_name,
    "emergency-last-name" => :emergency_contact_last_name,
    "emergency-contact-phone-number" => :emergency_contact_phone,
    "ps-cob" => :birth_country_country_name,
    "npi_number" => :npi,
    "has_dea_registration_number" => :dea_flag,
    "gi-country" => :country,
    "address_line_1" => :address_line_1,
    "address_line_2" => :address_line_2,
    "city" => :birth_city,
    "county" => :county,
    "ps-state" => :birth_state,
    "zipcode" => :zipcode,
    "telephone" => :telephone_number,
    "page_number" => :pager_beeper_number,
    "mobile_number" => :cell_phone_number,
    "fax_number" => :fax_number,
    "caqh_provider_id" => :caqh_number,
    "has_cds_registration_number" => :cds_flag,
    "signature_date" => :attest_date,
    "medicare_field" => :medicare_provider_flag,
    "medicaid_field" => :medicaid_provider_flag,
    "hp_health_plans" => :hp_health_plans,
    "hp_hospitals" => :hp_hospitals,
    "hp_directories" => :hp_directories,
    "undergraduate_school" => :other_graduate_education_flag,
    "has_training_program" =>  :fellowship_training_flag,
    "has_hospital_privilege" => :hospital_privilege_flag,
    "has_admitting_arrangement" => :hospital_admitting_arrangements,
    "has_malpractice_claim" => :no_malpractice_claims_flag
  }.freeze
end
