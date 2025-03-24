class RvaInformation < ApplicationRecord
	belongs_to :provider_personal_information, optional: true
	belongs_to :provider_dea, optional: true
	belongs_to :practice_information_education, optional: true
	belongs_to :provider_education, optional: true
	belongs_to :provider_specialty, optional: true
	belongs_to :provider_licensure, optional: true
	belongs_to :provider_insurance_coverage, optional: true
	belongs_to :provider_employment, optional: true
	has_many :dea_webcrawler_logs, dependent: :destroy
	has_many :oig_webcrawler_logs, dependent: :destroy
	has_many :licensure_webcrawler_logs, dependent: :destroy  
end
