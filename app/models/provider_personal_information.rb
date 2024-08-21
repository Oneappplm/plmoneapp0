class ProviderPersonalInformation < ApplicationRecord
  self.primary_key = :provider_id

  belongs_to :provider_attest

  validates :provider_attest, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}, #{provider_type_provider_type_abbreviation}"
end
