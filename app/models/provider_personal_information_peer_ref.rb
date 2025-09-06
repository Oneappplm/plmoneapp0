class ProviderPersonalInformationPeerRef < ApplicationRecord
  belongs_to :provider_attest

  def practitioner_name
    "#{first_name} #{middle_name} #{last_name}"
  end
end
