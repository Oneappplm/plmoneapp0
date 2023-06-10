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
	scope :submitted, -> { where(status: 'submitted') }
	scope :not_submitted, -> { where(status: 'not_submitted') }
	scope :approved, -> { where(status: 'approved') }
	scope :completed, -> { where(status: 'completed') }
	scope :pending, -> { where(status: 'pending') }
	scope :rejected, -> { where(status: 'rejected') }
  scope :callback, -> { where(status: 'callback') }
  scope :assigned, -> { where(status: 'assigned') }
  scope :terminated, -> { where(status: 'terminated') }
  scope :unassigned, -> { where(status: 'unassigned') }


  scope :this_month, -> { where(created_at: DateTime.now.beginning_of_month..DateTime.now.end_of_month) }
  scope :today, -> { where(created_at: DateTime.now) }
  scope :this_week, -> { where(created_at: DateTime.now.beginning_of_week..DateTime.now.end_of_month) }


	has_many :details, class_name: 'EnrollmentProvidersDetail'
  has_many :comments, class_name: 'EnrollmentComment'

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