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

  has_many :provider_personal_information_sam_records
  has_many :provider_personal_information_reinstatements
  has_many :provider_personal_information_comments
  has_many :provider_personal_information_app_trackings
  has_many :rva_informations, dependent: :destroy
  has_many :pdf_generation_queues, dependent: :destroy

  has_one :provider_personal_information_credentialing_contact
  has_one :provider_personal_information_confidential_contact

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
end
