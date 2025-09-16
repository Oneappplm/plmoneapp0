class ProviderPersonalInformationConfidentialContact < ApplicationRecord
  belongs_to :provider_personal_information

  def complete_address
    "#{address} #{address2} #{city} #{country}"
  end
end
