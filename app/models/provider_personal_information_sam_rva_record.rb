class ProviderPersonalInformationSamRvaRecord < ApplicationRecord
  belongs_to :provider_personal_information_sam_record

  mount_uploader :supporting_documentation, DocumentUploader
end
