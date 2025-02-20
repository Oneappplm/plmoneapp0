class SavedProfile < ApplicationRecord
  belongs_to :pdf_generation_queue
  mount_uploader :file_path, DocumentUploader
end
