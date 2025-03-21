class RvaInformation < ApplicationRecord
	belongs_to :provider_personal_information, optional: true
	belongs_to :provider_dea, optional: true
	belongs_to :practice_information_education, optional: true
	has_many :dea_webcrawler_logs, dependent: :destroy
	has_many :oig_webcrawler_logs, dependent: :destroy
end
