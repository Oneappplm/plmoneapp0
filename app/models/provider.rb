class Provider < ApplicationRecord
  mount_uploader :dco_file, DocumentUploader
  mount_uploader :school_certificate, DocumentUploader
  mount_uploader :caqh_pdf, DocumentUploader


  attr_accessor :dea_registration_state, :name_admitting_physician, :facility_location,
                :facility_name, :admitting_facility_address_line1, :admitting_facility_address_line2,
                :admitting_facility_city, :admitting_facility_zip_code, :admitting_facility_arrangments

  # validates_format_of :telephone_number, with: /\A\d{3}-\d{4}\z/, message: "should be in the format xxx-xxxx"
  # validates_format_of :ext, with: /\A\d{2}\z/, message: "should be in the format xx"

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
  def from_provider_title = "Local Provider"
end
