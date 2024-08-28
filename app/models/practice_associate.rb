class PracticeAssociate < ApplicationRecord
  self.primary_key = :provider_practice_associate_id

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: :provider_practice_id

  validates :provider_attest, presence: true
  validates :practice_information, presence: true

  has_many :practice_associate_other_questions, foreign_key: :provider_practice_associate_id
  has_many :practice_associate_specialties, foreign_key: :provider_practice_associate_id

  before_validation :set_provider_attest_id

  def assign_attributes_from_csv_row(row)
    self.assign_attributes({
      "associate_first_name": row["AssociateFirstName"],
      "associate_last_name": row["AssociateLastName"],
      "associate_middle_initial": row["AssociateMiddleInitial"],
      "address": row["Address"],
      "address2": row["Address2"],
      "city": row["City"],
      "state": row["State"],
      "zip": row["Zip"],
      "county": row["County"],
      "phone_number": row["PhoneNumber"],
      "fax_number": row["FaxNumber"],
      "email_address": row["EmailAddress"],
      "license_number": row["LicenseNumber"],
      "license_state": row["LicenseState"],
      "hospital_department_name": row["HospitalDepartmentName"],
      "check_payable_to": row["CheckPayableTo"],
      "electronic_billing_flag": row["ElectronicBillingFlag"],
      "coverage_flag": row["CoverageFlag"],
      "billing_company": row["BillingCompany"],
      "coverage_arrangement_explanation": row["CoverageArrangementExplanation"],
      "tax_id": row["TaxID"],
      "other_skills": row["OtherSkills"],
      "emergency_phone_number": row["EmergencyPhoneNumber"],
      "answering_service_phone_number": row["AnsweringServicePhoneNumber"],
      "title": row["Title"],
      "tax_id_name": row["TaxIDName"],
      "phone_extension": row["PhoneExtension"],
      "degree_degree_abbreviation": row["Degree_DegreeAbbreviation"],
      "provider_type_provider_type_abbreviation": row["ProviderType_ProviderTypeAbbreviation"],
      "associate_type_associate_type_description": row["AssociateType_AssociateTypeDescription"],
      "provider_practice_id": row["ProviderPracticeID"]
    })
  end

  private

  def set_provider_attest_id
    self.provider_attest_id = self.practice_information.provider_attest_id
  end
end
