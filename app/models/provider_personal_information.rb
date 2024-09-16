class ProviderPersonalInformation < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_id]

  ransacker :full_name do
    Arel.sql("CONCAT_WS(' ', provider_personal_informations.first_name, provider_personal_informations.last_name)")
  end

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  has_many :practice_informations, through: :provider_attest

  has_many :provider_personal_attempts, through: :provider_attest

  # for app_tracker
  has_many :provider_personal_docs_uploaded_documents, class_name: 'ProviderPersonalDocsUpload', through: :provider_attest

  has_one :provider_personal_docs_receive, through: :provider_attest

  # for verification_platform
  has_many :provider_personal_uploaded_docs, class_name: 'ProviderPersonalUploadedDoc', through: :provider_attest 

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}"
  def correspondence_address_type_correspondence_address_type_descripion = correspondence_address_type_correspondence_address_type_descrip
end
