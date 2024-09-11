class ProviderPersonalDocsReceive < ApplicationRecord
  self.primary_key = [:provider_id, :provider_attest_id]

  belongs_to :provider_attest
end
