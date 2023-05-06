class ProviderSourceDocument < ApplicationRecord
	mount_uploader :file_path, DocumentUploader
	belongs_to :provider_source, inverse_of: :documents, optional: true
end