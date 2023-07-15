class ProviderLicense < ApplicationRecord
  belongs_to :provider
  belongs_to :state
end
