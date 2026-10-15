class ProviderPersonalInformationComment < ApplicationRecord
  belongs_to :user
  belongs_to :provider_personal_information
end
