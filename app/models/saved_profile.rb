class SavedProfile < ApplicationRecord
  belongs_to :pdf_generation_queue
  mount_uploader :file_path, DocumentUploader
  before_destroy :remove_uploaded_file

  def remove_uploaded_file
    file_path.remove! if file_path.present?
  rescue => e
    Rails.logger.error "Error deleting file: #{e.message}"
  end

end
