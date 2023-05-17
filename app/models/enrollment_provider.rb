class EnrollmentProvider < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

  attr_accessor :npi

	mount_uploader :state_license_file, DocumentUploader
	mount_uploader :dea_file, DocumentUploader
	mount_uploader :irs_letter_file, DocumentUploader
	mount_uploader :w9_file, DocumentUploader
	mount_uploader :voided_check_file, DocumentUploader
	mount_uploader :curriculum_vitae_file, DocumentUploader
	mount_uploader :cms_460_file, DocumentUploader
	mount_uploader :eft_file, DocumentUploader
	mount_uploader :cert_insurance_file, DocumentUploader
	mount_uploader :driver_license_file, DocumentUploader
	mount_uploader :board_certification_file, DocumentUploader

	default_scope { order(:id) }

  has_many :details, class_name: 'EnrollmentProvidersDetail'

  accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank


	def provider_name
		provider =	if Provider.exists?(id: self.provider_id)
			Provider.find(self.provider_id)&.provider_name
		elsif ProviderSource.exists?(id: self.provider_id)
			ProviderSource.find(self.provider_id)&.provider_name
		else
			"N/A"
		end
	end

	def doc_submitted(doc)
			# auto check if file is not nil
			doc = self.send(doc)
			(doc && doc&.url.nil?) ? false : true
	end

	def doc_url(doc)
			doc = self.send(doc)
			(doc && doc&.url.present?) ? doc&.url : nil
	end

	def assigned_agent
		User.from_enrollment.find_by(id: self.user_id)
	end
end