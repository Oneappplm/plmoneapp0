class EnrollmentProvider < ApplicationRecord
	include PgSearch::Model
	include RemovePayorFiles

  pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

  attr_accessor :npi, :ssn

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
	scope :processing, -> { where(status: 'processing') }
	scope :denied, -> { where(status: 'denied') }
	scope :not_eligible, -> { where(status: 'not-eligible') }
	scope :this_month, -> { where(created_at: DateTime.now.beginning_of_month..DateTime.now.end_of_month) }
	scope :today, -> { where(created_at: DateTime.now) }
	scope :this_week, -> { where(created_at: DateTime.now.beginning_of_week..DateTime.now.end_of_month) }

	belongs_to :provider, optional: true

	has_one :client_provider_enrollment, as: :enrollable, dependent: :destroy
	has_many :details, class_name: 'EnrollmentProvidersDetail', dependent: :destroy
  has_many :comments, class_name: 'EnrollmentComment', dependent: :destroy

	accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank

 after_create :create_client_provider_enrollment

	def provider_name
		if self.outreach_type.present?
			if self.outreach_type == "provider-from-enrollment"
				Provider.find_by(id: self.provider_id)&.provider_name
			else
				ProviderSource.find_by(id: self.provider_id)&.provider_name
			end
		else
			provider =	if Provider.exists?(id: self.provider_id)
				Provider.find_by(id: self.provider_id)&.provider_name
			elsif ProviderSource.exists?(id: self.provider_id)
				ProviderSource.find_by(id: self.provider_id)&.provider_name
			else
				"N/A"
			end
		end
	end

	def selected_providers
     self.provider ? self.provider.split(',') : nil
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

	def create_client_provider_enrollment
    ClientProviderEnrollment.create(enrollable: self)
  end

  def full_name
    "#{self.first_name} #{self.middle_name} #{self.last_name} #{self.suffix}"
  end

	def self.enrollment_types
		if Setting.take.dcs?
			[
				['Initial','initial'],
				['Re-Credential','re_credential'],
				['Terminate Contract','terminate_contract'],
				['Add Location','add_location'],
				['TIN Change','tin_change']
			]
		else
			[
				['Add','add'],
				['Initial','Initial'],
				['Recred/Reval','recred'],
				['Not part on contract','not_part_on_contract']
			]
		end
	end
end