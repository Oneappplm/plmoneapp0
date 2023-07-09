class Provider < ApplicationRecord
  has_one :licenses , class_name: 'ProviderLicense', dependent: :destroy
end

class Provider < ApplicationRecord
  include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

  mount_uploader :school_certificate, DocumentUploader
  mount_uploader :state_license_copy_file, DocumentUploader
  mount_uploader :dea_copy_file, DocumentUploader
  mount_uploader :w9_form_file, DocumentUploader
  mount_uploader :certificate_insurance_file, DocumentUploader
  mount_uploader :drivers_license_file, DocumentUploader
  mount_uploader :board_certification_file, DocumentUploader
  mount_uploader :caqh_app_copy_file, DocumentUploader
  mount_uploader :cv_file, DocumentUploader
  mount_uploader :telehealth_license_copy_file, DocumentUploader


  # validates_format_of :telephone_number, with: /\A\d{3}-\d{4}\z/, message: "should be in the format xxx-xxxx"
  # validates_format_of :ext, with: /\A\d{2}\z/, message: "should be in the format xx"


  belongs_to :group, class_name: 'EnrollmentGroup', foreign_key: 'enrollment_group_id', optional: true
  belongs_to :group_dco, class_name: 'GroupDco', foreign_key: 'dco', optional: true
  belongs_to :state, class_name: 'State', foreign_key: 'state_id', required: true

  # has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_one :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy
  has_many :service_locations , class_name: 'ProvidersServiceLocation', dependent: :destroy
  has_many :comments, class_name: 'EnrollmentComment'
  # made it like this to prepare if needed to be multiple
  has_many :pa_licenses, class_name: 'ProviderPaLicense', dependent: :destroy
  has_many :dea_licenses, class_name: 'ProviderDeaLicense', dependent: :destroy
  has_many :mn_licenses, class_name: 'ProviderMnLicense', dependent: :destroy
  has_many :mccs, class_name: 'ProviderMcc', dependent: :destroy
  has_many :mn_medicaids, class_name: 'ProviderMnMedicaid', dependent: :destroy
  has_many :medicaids, class_name: 'ProviderMedicaid', dependent: :destroy
  has_many :wi_medicaids, class_name: 'ProviderWiMedicaid', dependent: :destroy
  has_many :medicares, class_name: 'ProviderMedicare', dependent: :destroy
  has_many :cnp_licenses, class_name: 'ProviderCnpLicense', dependent: :destroy
  has_many :ins_policies, class_name: 'ProviderInsPolicy', dependent: :destroy
  has_many :time_lines, class_name: 'ProvidersTimeLine', dependent: :destroy

  # accepts_nested_attributes_for :taxonomies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :np_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :rn_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :service_locations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pa_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :dea_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mn_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mccs, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mn_medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :wi_medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medicares, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :cnp_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :ins_policies, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :first_name, :last_name, :birth_date, :practitioner_type,
    :ssn, :gender, :city, :state, :telephone_number, :email_address

  default_scope { where(api_token: nil) }
  scope :male, -> { where(gender: 'Male') }
  scope :female, -> { where(gender: 'Female') }
  scope :non_binary, -> { where(gender: 'Non Binary') }


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

  def doc_submitted(doc)
    # auto check if file is not nil
    doc = self.send(doc)
    (doc && doc&.url.nil?) ? false : true
  end

  def doc_url(doc)
    doc = self.send(doc)
    (doc && doc&.url.present?) ? doc&.url : nil
  end

  def selected_practitioner_types
    self.practitioner_type ? self.practitioner_type.split(',') : ''
  rescue
    ''
  end

  def selected_specialties
    self.specialty ? self.specialty.split(',') : ''
  rescue
    ''
  end
end
