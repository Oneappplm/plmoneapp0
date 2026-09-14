class ProviderPersonalInformationPeerRef < ApplicationRecord
  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy


  def practitioner_name
    "#{first_name} #{middle_name} #{last_name}"
  end
end
