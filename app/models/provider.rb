class Provider < ApplicationRecord
  include PgSearch::Model

  REQUIRED_ATTRIBUTES = [
                          'first_name', 'last_name', 'birth_date',
                          'birth_city', 'birth_state', 'address_line_1',
                          'ssn','city','state_id','zip_code','practitioner_type',
                          'taxonomy','specialty', 'enrollment_group_id'
                        ]
  REQUIRED_DOCUMENTS = [
                          'state_license_copy_file', 'dea_copy_file', 'w9_form_file',
                          'certificate_insurance_file', 'drivers_license_file', 'board_certification_file',
                          'caqh_app_copy_file', 'telehealth_license_copy_file', 'school_certificate', 'cv_file'
                       ]

  ALL_REQUIRED_FIELDS = REQUIRED_ATTRIBUTES + REQUIRED_DOCUMENTS

  REQUIRED_LICENSE_ATTRIBUTES = ['license_number', 'license_effective_date', 'license_expiration_date', 'state_id']

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
  belongs_to :state, class_name: 'State', foreign_key: 'state_id', required: false

  has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_one :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_one :enrollment_provider , class_name: 'EnrollmentProvider', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy
  has_many :service_locations , class_name: 'ProvidersServiceLocation', dependent: :destroy
  has_many :comments, class_name: 'EnrollmentComment'
  # made it like this to prepare if needed to be multiple
  has_many :pa_licenses, class_name: 'ProviderPaLicense', dependent: :destroy
  has_many :dea_licenses, class_name: 'ProviderDeaLicense', dependent: :destroy
  has_many :cds_licenses, class_name: 'ProviderCdsLicense', dependent: :destroy
  has_many :mn_licenses, class_name: 'ProviderMnLicense', dependent: :destroy
  has_many :mccs, class_name: 'ProviderMcc', dependent: :destroy
  has_many :mn_medicaids, class_name: 'ProviderMnMedicaid', dependent: :destroy
  has_many :medicaids, class_name: 'ProviderMedicaid', dependent: :destroy
  has_many :wi_medicaids, class_name: 'ProviderWiMedicaid', dependent: :destroy
  has_many :medicares, class_name: 'ProviderMedicare', dependent: :destroy
  has_many :cnp_licenses, class_name: 'ProviderCnpLicense', dependent: :destroy
  has_many :ins_policies, class_name: 'ProviderInsPolicy', dependent: :destroy
  has_many :time_lines, class_name: 'ProvidersTimeLine', dependent: :destroy
  has_many :deleted_document_logs, class_name: 'ProviderDeletedDocumentLog', dependent: :destroy
  has_many :missing_field_submissions, class_name: 'ProvidersMissingFieldSubmission',dependent: :destroy
  has_many :payer_logins, class_name: 'ProvidersPayerLogin', dependent: :destroy

  # accepts_nested_attributes_for :taxonomies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :np_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :rn_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :service_locations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pa_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :dea_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :cds_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mn_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mccs, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :mn_medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :wi_medicaids, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medicares, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :cnp_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :ins_policies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :payer_logins, allow_destroy: true, reject_if: :all_blank

  scope :selected_first, -> { order(selected: :desc) }
  default_scope { where(api_token: nil) }
  scope :male, -> { where(gender: 'Male') }
  scope :female, -> { where(gender: 'Female') }
  scope :non_binary, -> { where(gender: 'Non Binary') }
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }

  after_create :send_welcome_letter


   def self.with_missing_required_attributes
    joins("LEFT JOIN provider_licenses ON providers.id = provider_licenses.provider_id")
      .where(
        ALL_REQUIRED_FIELDS.map { |attr| "providers.#{attr} IS NULL" }.join(' OR ')
      )
  end
  # had to separate this since if I combine them in the query above it's not giving proper results
  def self.with_missing_license_attributes
    joins("LEFT JOIN provider_licenses ON providers.id = provider_licenses.provider_id")
      .where(
        REQUIRED_LICENSE_ATTRIBUTES.map { |attr| "provider_licenses.#{attr} IS NULL" }.join(' OR ')
      )
  end

  class << self
    def search_by_params(params)
      return all if client_portal_conditions(params).values.all?(&:blank?)

      results = if params[:practitioner_type].present?
        practitioner_types = params[:practitioner_type].split(',').map(&:strip).reject(&:blank?)
        conditions = practitioner_types.map { |type| "practitioner_type ILIKE ?" }
        wildcards = practitioner_types.map { |type| "%#{type}%" }

        where(client_portal_conditions(params.except(:practitioner_type)).reject { |k, v| v.blank? }.compact)
          .where(conditions.join(" OR "), *wildcards)
      else
        where(client_portal_conditions(params).reject { |k, v| v.blank? }.compact)
      end
    end

    def client_portal_conditions(params)
      {
        status: params[:status],
        enrollment_group_id: params[:provider_enrollment_group_id],
        first_name: params[:first_name],
        middle_name: params[:middle_name],
        last_name: params[:last_name],
        practitioner_type: (params[:practitioner_type].split(',') rescue ''),
        npi: params[:npi],
        ssn: params[:ssn],
        dco: params[:provider_dco]
      }
    end

    def with_missing_required_fields
      query_conditions = REQUIRED_ATTRIBUTES.map { |field| "#{field} IS NULL" }.join(' OR ')
      Provider.where(query_conditions)
    end

    def with_missing_required_docs
      query_conditions = REQUIRED_DOCUMENTS.map { |field| "#{field} IS NULL" }.join(' OR ')
      Provider.where(query_conditions)
    end
  end

  def provider_name = "#{first_name} #{middle_name} #{last_name}"
  def from_provider_title = "Local Provider"
  def client = group
  def location = group_dco
  def practitioner = selected_practitioner_types.join(',') rescue nil

  def fetch(key = nil,attribute=nil)
    finder(key, attribute)&.data_value
  end

  def finder(field = nil,attribute=nil)
    missing_field_submissions.find_by(data_key: field, provider_id: self.id, data_attribute: attribute)
  end

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

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def selected_birth_state
    State.find(self.birth_state)
  rescue
    nil
  end

  def formatted_phone
    "#{self.ext} #{self.telephone_number}"
    rescue nil
  end

  def licensed_registered_state
    State.find(self.birth_state)
  rescue
    nil
  end

  def required_documents
    [
     ['State License Copy', 'state_license_copy_file'],
     ['DEA Copy', 'dea_copy_file'],
     ['W9 Form', 'w9_form_file' ],
     ['Certificate of Insurance', 'certificate_insurance_file'],
     ['Drivers License', 'drivers_license_file' ],
     ['License Registered State', 'board_certification_file' ],
     ['CAQH App Copy', 'caqh_app_copy_file' ],
     ['Curriculum Vitae (CV)', 'cv_file' ],
     ['Telehealth License Copy', 'telehealth_license_copy_file'],
     ['Copy of Certificate', 'school_certificate']
   ]
  end

  # needed on notification page http://localhost:3000/enrollment-clients/:id?mode=notifications
  def required_fields
    [
      ['First Name', 'first_name', 'text_field'],
      ['Last Name', 'last_name', 'text_field'],
      ['SSN', 'ssn', 'text_field'],
      ['Date of birth', 'birth_date', 'date_field'],
      ['Birth City', 'birth_city', 'text_field'],
      ['Birth State', 'birth_state', 'state_dropdown'],
      ['Address Line 1', 'address_line_1', 'text_field'],
      ['City', 'city','text_field'],
      ['State','state_id', 'state_dropdown'],
      ['Zip Code', 'zip_code', 'text_field'],
      ['Practitioner Type', 'practitioner_type', 'practitioner_dropdown'],
      ['Taxonomy', 'taxonomy', 'text_field'],
      ['Specialty', 'specialty', 'specialty_dropdown'],
      ['Client','enrollment_group_id','client_dropdown'],
    ]
  end

  def required_state_licenses_fields
    [
      ['State License Number', 'license_number', 'text_field'],
      ['License Effective Date', 'license_effective_date', 'date_field'],
      ['License Registration State', 'state_id', 'state_dropdown'],
      ['License Expiration Date', 'license_expiration_date', 'date_field']
    ]
  end

  def has_missing_documents
    required_documents.each do |field|
      return true if self.send(field[1]).nil? or self.send(field[1])&.url.nil?
    end
    return false
  end

  def has_missing_required_fields?
    required_fields.each do |field|
      return true if self.send(field[1]).nil? or self.send(field[1]).blank?
    end
    return false
  end

  def has_missing_state_licenses_fields?
    licenses_required_fields = ['license_number','license_effective_date', 'license_expiration_date', 'state_id']
    licenses_required_fields.each do |field|
      return true if licenses.send(field).nil? or licenses.send(field).blank?
    end
    return false
  end

  def show_missing_fields?
    has_missing_required_fields? or licenses.nil? or has_missing_state_licenses_fields?
  end

  def create_missing_field_submission
    ProvidersMissingFieldSubmission.create(provider_id: self.id)
  end

  def is_payer_login?
    self.payer_login == 'yes'
  end

  def admitting_state
    State.find_by(id: self.admitting_facility_state)&.name
  rescue
    ''
  end

  def caqh_state_name
    State.find_by(id: self.caqh_state)&.name
  rescue
    ''
  end

  def pending_submitted_documents
    self.missing_field_submissions.pending.map{|m| m.data.where(data_attribute: 'upload').pluck(:data_key)}.reject(&:empty?).flatten
  rescue
    []
  end

  def send_welcome_letter
    return unless self.email_address.present?

    PlmMailer.with(email: self.email_address, attachments: ['welcome-letter-new-provider.docx']).welcome_letter.deliver_now
  end
end
