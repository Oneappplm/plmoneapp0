class ProviderDeaLicense < ApplicationRecord
  belongs_to :provider
  belongs_to :state
end