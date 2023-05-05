class Provider < ApplicationRecord
  # note to jayson only added telephone here to not cause error on show page
  # telephone should be a combination of ext (xx) telephone_number xxx-xxxx e.g. (08) 992-2312
  # revalidation can be boolean or string as long as the display can be YES or NO
  # employed_by_other can also be boolean as long as the display can be shown as YES or NO
  # supervised can also be boolean as long as the display can be shown as YES or NO
  
  attr_accessor :address1, :city, :state, :telephone,
                :email, :hire_date, :effective_date,
                :admitting_privileges, :revalidation,
                :employed_by_other, :supervised, :school_name,
                :school_address, :graduation_date, :medicare_number,
                :medicaid_number, :tricare_number, :telehealth_number,
                :board_certificate_number, :dea_state, :caqh_username,
                :caqh_username, :caqh_password, :caqh_state, :caqh_app,
                :caqh_payor




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
