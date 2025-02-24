class ProviderPersonalDocsReceive < ApplicationRecord
  belongs_to :provider_attest
  belongs_to :provider_personal_information
end
