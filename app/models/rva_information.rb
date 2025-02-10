class RvaInformation < ApplicationRecord
	belongs_to :provider_personal_information
	has_many :oig_webcrawler_logs, dependent: :destroy
end
