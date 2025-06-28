class ProviderSourceSpeciality < ApplicationRecord
  belongs_to :provider_source
  belongs_to :provider_personal_information
end
