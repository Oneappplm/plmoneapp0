class ProviderPersonalInformation < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}, #{provider_type_provider_type_abbreviation}"
  def correspondence_address_type_correspondence_address_type_descripion = correspondence_address_type_correspondence_address_type_descrip
end
