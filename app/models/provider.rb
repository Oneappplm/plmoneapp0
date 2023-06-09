class Provider < ApplicationRecord
  mount_uploader :dco_file, DocumentUploader
  mount_uploader :school_certificate, DocumentUploader

  # validates_format_of :telephone_number, with: /\A\d{3}-\d{4}\z/, message: "should be in the format xxx-xxxx"
  # validates_format_of :ext, with: /\A\d{2}\z/, message: "should be in the format xx"


  belongs_to :group, class_name: 'EnrollmentGroup', foreign_key: 'enrollment_group_id', optional: true
  belongs_to :group_dco, class_name: 'GroupDco', foreign_key: 'dco', optional: true

  has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_many :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy
  has_many :comments, class_name: 'EnrollmentComment'

  accepts_nested_attributes_for :taxonomies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :np_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :rn_licenses, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :first_name, :last_name, :birth_date, :practitioner_type,
    :ssn, :npi

  default_scope { where(api_token: nil) }

  def provider_name = "#{first_name} #{middle_name} #{last_name}"
  def from_provider_title = "Local Provider"

  def enrollments
    EnrollmentProvider.where(provider_id: self.id)
  end

  def no_group?
    self.enrollment_group_id.nil? && self.dco.nil?
  end

  def attested
    Client.attested.where(provider_name: provider_name).count
  end

  def completed
    Client.complete.where(provider_name: provider_name).count
  end

  def incomplete
    Client.incomplete.where(provider_name: provider_name).count
  end

  def returned
    Client.returned.where(provider_name: provider_name).count
  end

  def pending
    Client.pending_data.where(provider_name: provider_name).count
  end
end
