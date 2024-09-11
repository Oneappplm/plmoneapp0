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
end
