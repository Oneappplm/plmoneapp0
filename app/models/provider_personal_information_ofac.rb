class ProviderPersonalInformationOfac < ApplicationRecord
  belongs_to :provider_personal_information

  mount_uploader :supporting_document, DocumentUploader if defined?(DocumentUploader)

  SEARCH_RESULTS = [
    "No Match",
    "Match",
    "Pending",
    "Not Available"
  ].freeze
end
