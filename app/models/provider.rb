class Provider < ApplicationRecord
  include PgSearch::Model
		audited

  REQUIRED_ATTRIBUTES = [
                          'first_name', 'last_name', 'birth_date',
                          'birth_city', 'birth_state', 'address_line_1',
                          'ssn','city','state_id','zip_code','practitioner_type',
                          'taxonomy','specialty', 'enrollment_group_id'
                        ]
  REQUIRED_DOCUMENTS = [
                          'state_license_copies', 'dea_copies', 'w9_form_copies',
                          'certificate_insurance_copies', 'driver_license_copies', 'board_certification_copies',
                          'caqh_app_copies', 'cv_copies', 'telehealth_license_copies', 'school_certificate'
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
  mount_uploaders :welcome_letter_attachments, DocumentUploader
  mount_uploaders :state_license_copies, DocumentUploader
  mount_uploaders :dea_copies, DocumentUploader
  mount_uploaders :w9_form_copies, DocumentUploader
  mount_uploaders :certificate_insurance_copies, DocumentUploader
  mount_uploaders :driver_license_copies, DocumentUploader
  mount_uploaders :board_certification_copies, DocumentUploader
  mount_uploaders :caqh_app_copies, DocumentUploader
  mount_uploaders :cv_copies, DocumentUploader
  mount_uploaders :telehealth_license_copies, DocumentUploader

  # validates_format_of :telephone_number, with: /\A\d{3}-\d{4}\z/, message: "should be in the format xxx-xxxx"
  # validates_format_of :ext, with: /\A\d{2}\z/, message: "should be in the format xx"

  belongs_to :client, optional: true

  belongs_to :group, class_name: 'EnrollmentGroup', foreign_key: 'enrollment_group_id', optional: true
  # relationhsip to be removed - update: provider can have many group_dcos
  belongs_to :group_dco, class_name: 'GroupDco', foreign_key: 'dco', optional: true
  belongs_to :state, class_name: 'State', foreign_key: 'state_id', required: false
  belongs_to :prof_medical_school_state, class_name: 'State', foreign_key: 'prof_medical_school_state_id', required: false
  has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_many :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_one :enrollment_provider , class_name: 'EnrollmentProvider', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy
  has_many :board_certifications , class_name: 'ProviderBoardCertification', dependent: :destroy
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
  has_many :missing_field_submissions, class_name: 'ProvidersMissingFieldSubmission', dependent: :destroy
  has_many :payer_logins, class_name: 'ProvidersPayerLogin', dependent: :destroy
  has_many :enrollments, class_name: 'EnrollmentProvider', dependent: :destroy
  has_many :notes, class_name: 'ProviderNote', dependent: :destroy
		has_many :uploaded_documents, class_name: 'ProviderUploadedDocument', dependent: :destroy
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
  accepts_nested_attributes_for :board_certifications, allow_destroy: true, reject_if: :all_blank

  scope :selected_first, -> { order(selected: :desc) }
  default_scope { where(api_token: nil) }
  default_scope { order(:last_name) }
  scope :male, -> { where(gender: 'Male') }
  scope :female, -> { where(gender: 'Female') }
  scope :non_binary, -> { where(gender: 'Non Binary') }
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive-termed') }
  scope :search_by_condition, -> (params) {
    conditions = {}
    conditions[:first_name] = params[:first_name].titleize if params[:first_name].present?
    conditions[:last_name] = params[:last_name].titleize if params[:last_name].present?
    conditions[:npi] = params[:npi] if params[:npi].present?

    where(conditions)
  }

  after_save :send_welcome_letter

  def self.displayable_attributes
    %i[id first_name middle_name last_name birth_date practitioner_type ssn caqhid
    ]
  end

  # this is for all required fields including uploads
  def self.with_missing_required_attributes
    joins("LEFT JOIN provider_licenses ON providers.id = provider_licenses.provider_id")
      .where(
        ALL_REQUIRED_FIELDS.map { |attr| "providers.#{attr} IS NULL" }.join(' OR ')
      )
  end

  # Used to filter with missing fields(not upload) only
  def self.with_missing_field_fields
    where(REQUIRED_ATTRIBUTES.map{|attr| "providers.#{attr} IS NULL" }.join(' OR '))
  end

  # Used to filter with missing documents(uploads only) only
  def self.with_missing_documents
    where(REQUIRED_DOCUMENTS.map{|attr| "providers.#{attr} IS NULL" }.join(' OR '))
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
      return all if client_portal_conditions(params).values.all?(&:blank?) && client_name_conditions(params).values.all?(&:blank?)

      results = if params[:practitioner_type].present?
        practitioner_types = params[:practitioner_type].split(',').map(&:strip).reject(&:blank?)
        conditions = practitioner_types.map { |type| "practitioner_type ILIKE ?" }
        wildcards = practitioner_types.map { |type| "%#{type}%" }

        where(client_portal_conditions(params.except(:practitioner_type)).reject { |k, v| v.blank? }.compact)
          .where(conditions.join(" OR "), *wildcards)
      elsif params[:first_name].present? or params[:last_name].present? or params[:middle_name].present?
        # need to refactor this in the future
        name_conditions = []
        if params[:first_name].present?
          name_conditions << " first_name ILIKE '%#{params[:first_name]}%'"
        end

        if params[:last_name].present?
          name_conditions << " last_name ILIKE '%#{params[:last_name]}%'"
        end

        if params[:middle_name].present?
          name_conditions << " middle_name ILIKE '%#{params[:middle_name]}%'"
        end
        query = if name_conditions.count > 1
          name_conditions.join(" OR ")
        else
          name_conditions.join("")
        end
        where(query)
      else
        where(client_portal_conditions(params).reject { |k, v| v.blank? }.compact)
      end
    end

    def client_portal_conditions(params)
      {
        status: params[:status],
        enrollment_group_id: params[:provider_enrollment_group_id],
        practitioner_type: (params[:practitioner_type].split(',') rescue ''),
        npi: params[:npi],
        ssn: params[:ssn],
        dco: params[:provider_dco]
      }
    end

    def client_name_conditions(params)
      {
        first_name: params[:first_name],
        last_name: params[:last_name],
        middle_name: params[:middle_name]
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

    def format_names
      Provider.all.each do |provider|
        provider.update_attribute("first_name", provider&.first_name&.strip)
        provider.update_attribute("last_name", provider&.last_name&.strip)
        provider.update_attribute("middle_name", provider&.middle_name&.strip)
      end
    end

    # no differentiation beetween first_name last_name middle_name
    def search_name(searched_name)
      where("first_name ILIKE :name OR last_name ILIKE :name OR middle_name ILIKE :name", name: "%#{searched_name}%")
    end

    def filter_by_missing_field(field)
      if ['state_id', 'birth_date', 'enrollment_group_id', 'zip_code'].include?(field)
        where("#{field}": nil)
      else
        where("#{field} is NULL OR #{field} = ''")
      end
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

  # def enrollments
  #   EnrollmentProvider.where(provider_id: self.id)
  # end

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

    doc && doc.size > 0
  end

  def doc_url(doc)
    doc = send(doc)
    return [] unless doc.present? || (doc.kind_of?(Array) && doc.size > 0) || (doc.kind_of?(String) && doc.present?)

    if doc.kind_of?(Array)
      doc.map(&:url)
    else
      [doc.url]
    end
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
    "(#{self.ext}) #{self.telephone_number}"
    rescue nil
  end

  def licensed_registered_state
    State.find(self.licensed_registered_state_id)
  rescue
    nil
  end

  def prof_liability_state
    State.find(self.prof_liability_state_id)
  rescue
    nil
  end

  def required_documents
    [
     ['State License Copy', 'state_license_copies'],
     ['DEA Copy', 'dea_copies'],
     ['W9 Form', 'w9_form_copies' ],
     ['Certificate of Insurance', 'certificate_insurance_copies'],
     ['Drivers License', 'driver_license_copies' ],
     ['License Registered State', 'board_certification_copies' ],
     ['CAQH App Copy', 'caqh_app_copies' ],
     ['Curriculum Vitae (CV)', 'cv_copies' ],
     ['Telehealth License Copy', 'telehealth_license_copies'],
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
      ['License Expiration Date', 'license_expiration_date', 'date_field'],
      ['License Type', 'license_type', 'text_field']
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
    licenses_required_fields = ['license_number','license_effective_date', 'license_expiration_date', 'state_id', 'license_type']
    licenses.each do |license|
      licenses_required_fields.each do |field|
        return true if license.send(field).nil? or license.send(field).blank? or !license.persisted?
      end
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

  def submitted_missing_fields
    if self.missing_field_submissions
      self.missing_field_submissions.map{|m| m.data.map{|d| d.data_key}}.flatten.uniq
    else
      []
    end
  rescue
    []
  end

  def send_welcome_letter
    return unless self.email_address.present? && self.welcome_letter_status? && self.welcome_letter_sent.nil?

    attachments = []

    if welcome_letter_attachments.present?
      attachments = welcome_letter_attachments.map{|a| a.url}
    end

    attachments << "Welcome Letter Existing Providers v3_Rebranded.docx" if check_welcome_letter
    attachments << "CO CAQH Authorization-Attestation and Release Forms.pdf" if check_co_caqh
    attachments << "MN CAQH State Release Form.pdf" if check_mn_caqh_state_release_form
    attachments << "MN CAQH Authorization Form.pdf" if check_mn_caqh_authorization_form
    attachments << "CAQH Standard Authorization.pdf" if check_caqh_standard_authorization

				email_addresses = email_address.split(',').map(&:strip).reject(&:blank?)
				email = email_addresses.delete_at(0)	# remove first element


    PlmMailer.with(
      email: email,
      subject: welcome_letter_subject,
      body: simple_format(welcome_letter_message),
      attachments: attachments,
      folder_name: 'provider',
						cc: email_addresses
    ).welcome_letter.deliver_now

				update_columns(welcome_letter_sent: Date.today) if email.present?

    # attachments
  end

		def sent_welcome_letter?
			welcome_letter_status? && welcome_letter_sent.present?
		end

  def group_dcos
    GroupDco.where(id: self.dcos.split(",")) rescue []
  end

  def remove_state_license_copies
    remove_state_license_copies! unless state_license_copies.present?
  end

  def remove_dea_copies
    remove_dea_copies! unless dea_copies.present?
  end

  def remove_w9_form_copies
    remove_w9_form_copies! unless w9_form_copies.present?
  end

  def remove_certificate_insurance_copies
    remove_certificate_insurance_copies! unless certificate_insurance_copies.present?
  end

  def remove_driver_license_copies
    remove_driver_license_copies! unless driver_license_copies.present?
  end

  def remove_board_certification_copies
    remove_board_certification_copies! unless board_certification_copies.present?
  end

  def remove_caqh_app_copies
    remove_caqh_app_copies! unless caqh_app_copies.present?
  end

  def remove_cv_copies
    remove_cv_copies! unless cv_copies.present?
  end

  def remove_telehealth_license_copies
    remove_telehealth_license_copies! unless telehealth_license_copies.present?
  end
end
