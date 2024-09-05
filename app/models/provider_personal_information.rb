class ProviderPersonalInformation < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_id]

  ransacker :full_name do
    Arel.sql("CONCAT_WS(' ', provider_personal_informations.first_name, provider_personal_informations.last_name)")
  end

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  has_many :practice_informations, through: :provider_attest

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}"
  def correspondence_address_type_correspondence_address_type_descripion = correspondence_address_type_correspondence_address_type_descrip
end
