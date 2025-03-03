class ProviderSourceLicensure < ApplicationRecord
  self.table_name = 'provider_sources_licensure'
  belongs_to :provider_source, optional: true  
end
