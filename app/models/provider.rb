class Provider < ApplicationRecord
  has_many :taxonomies, class_name: 'ProviderTaxonomy', dependent: :destroy
  has_many :licenses , class_name: 'ProviderLicense', dependent: :destroy
  has_many :np_licenses , class_name: 'ProviderNpLicense', dependent: :destroy
  has_many :rn_licenses , class_name: 'ProviderRnLicense', dependent: :destroy

  accepts_nested_attributes_for :taxonomies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :np_licenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :rn_licenses, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :first_name, :middle_name, :last_name, :gender, :birth_date, :practitioner_type,
    :ssn, :npi, :caqhid

  def provider_name = "#{first_name} #{middle_name} #{last_name}"
  def provider_degree = nil
end
