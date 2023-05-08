class Provider < ApplicationRecord
  mount_uploader :dco_file, DocumentUploader
  mount_uploader :school_certificate, DocumentUploader
  mount_uploader :caqh_pdf, DocumentUploader

  validates_format_of :telephone_number, with: /\A\d{3}-\d{4}\z/, message: "should be in the format 992-2312"
  validates_format_of :ext, with: /\A\d{2}\z/, message: "should be in the format 08"

  # attr_accessor :address1, :city, :state, :telephone,
  #               :email, :hire_date, :effective_date,
  #               :admitting_privileges, :revalidation,
  #               :employed_by_other, :supervised, :school_name,
  #               :school_address, :graduation_date, :medicare_number,
  #               :medicaid_number, :tricare_number, :telehealth_number,
  #               :board_certificate_number, :dea_state, :caqh_username,
  #               :caqh_username, :caqh_password, :caqh_state, :caqh_app,
  #               :caqh_payor, :address_line_1, :address_line_2, :telephone_number,
  #               :ext, :email_address, :provider_hire_date_seeing_patient, :effective_date_seeing_patient,
  #               :medicare_provider_number, :medicaid_provider_number, :tricare_provider_number,
  #               :medical_school_name, :medical_school_address, :school_certificate, :telehealth_license_number,
  #               :board_certification_number

  has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_many :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy

  accepts_nested_attributes_for :taxonomies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :np_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :rn_licenses, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :first_name, :last_name, :birth_date, :practitioner_type,
    :ssn, :npi

  def provider_name = "#{first_name} #{middle_name} #{last_name}"
  def provider_degree = nil
end
