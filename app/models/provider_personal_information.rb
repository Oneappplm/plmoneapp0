class ProviderPersonalInformation < ApplicationRecord
  ransacker :full_name do
    Arel.sql("CONCAT_WS(' ', provider_personal_informations.first_name, provider_personal_informations.last_name)")
  end

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  has_many :practice_informations, through: :provider_attest
  has_many :provider_personal_attempts
  has_many :provider_personal_docs_uploaded_documents, class_name: 'ProviderPersonalDocsUpload'
  has_many :provider_personal_uploaded_docs, class_name: 'ProviderPersonalUploadedDoc'
  has_one :provider_personal_docs_receive

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}"
  def correspondence_address_type_correspondence_address_type_descripion = correspondence_address_type_correspondence_address_type_descrip

  before_validation :set_provider_attest
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end
