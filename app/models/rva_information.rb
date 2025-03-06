class RvaInformation < ApplicationRecord
	belongs_to :provider_personal_information
	has_many :dea_webcrawler_logs, dependent: :destroy
	has_many :oig_webcrawler_logs, dependent: :destroy
end
