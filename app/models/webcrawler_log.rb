class WebcrawlerLog < ApplicationRecord
	mount_uploader :filepath, DocumentUploader
end
