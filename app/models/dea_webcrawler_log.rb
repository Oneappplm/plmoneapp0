class DeaWebcrawlerLog < ApplicationRecord
  belongs_to :rva_information

  mount_uploader :filepath, DocumentUploader
  mount_uploader :html_filepath, DeaHtmlUploader

  scope :completed, -> { where(status: "completed") }

  def absolute_file_path
    return nil if filepath.blank?

    if filepath.respond_to?(:path)
      filepath.path
    elsif filepath.respond_to?(:current_path)
      filepath.current_path
    end
  end
end
