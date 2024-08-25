class ProviderPersonalInformation < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  def fullname = "#{last_name}, #{first_name} #{middle_name}, #{provider_type_provider_type_abbreviation}"

  def assign_attributes_from_csv_row(row)
    self.assign_attributes({
      "last_name": row["LastName"],
      "first_name": row["FirstName"],
      "middle_name": row["MiddleName"],
      "suffix": row["Suffix"],
      "primary_practice_state": row["PrimaryPracticeState"],
      "other_name_flag": row["OtherNameFlag"],
      "birth_date": row["BirthDate"],
      "us_eligible_flag": row["USEligibleFlag"],
      "ssn": row["SSN"],
      "nid": row["NID"],
      "dea_flag": row["DEAFlag"],
      "cds_flag": row["CDSFlag"],
      "upin": row["UPIN"],
      "upin_flag": row["UPINFlag"],
      "npi_flag": row["NPIFlag"],
      "npi": row["NPI"],
      "medicare_provider_flag": row["MedicareProviderFlag"],
      "medicaid_provider_flag": row["MedicaidProviderFlag"],
      "other_graduate_education_flag": row["OtherGraduateEducationFlag"],
      "fellowship_training_flag": row["FellowshipTrainingFlag"],
      "teaching_appointment_flag": row["TeachingAppointmentFlag"],
      "secondary_specialty_flag": row["SecondarySpecialtyFlag"],
      "other_specialty_flag": row["OtherSpecialtyFlag"],
      "hospital_privilege_flag": row["HospitalPrivilegeFlag"],
      "hospital_admitting_arrangements": row["HospitalAdmittingArrangements"],
      "work_history_gap_flag": row["WorkHistoryGapFlag"],
      "active_military_flag": row["ActiveMilitaryFlag"],
      "citizenship_status": row["CitizenshipStatus"],
      "visa_number": row["VisaNumber"],
      "federal_employee_id": row["FederalEmployeeID"],
      "no_malpractice_claims_flag": row["NoMalpracticeClaimsFlag"],
      "application_type": row["ApplicationType"],
      "ecfmg_flag": row["ECFMGFlag"],
      "ecfmg_number": row["ECFMGNumber"],
      "ecfmg_issue_date": row["ECFMGIssueDate"],
      "hospital_based_flag": row["HospitalBasedFlag"],
      "email_address": row["EmailAddress"],
      "visa_type": row["VisaType"],
      "visa_status": row["VisaStatus"],
      "birth_city": row["BirthCity"],
      "birth_state": row["BirthState"],
      "tax_id": row["TaxID"],
      "spouse_last_name": row["SpouseLastName"],
      "spouse_first_name": row["SpouseFirstName"],
      "other_correspondence_address": row["OtherCorrespondenceAddress"],
      "emergency_contact_last_name": row["EmergencyContactLastName"],
      "emergency_contact_first_name": row["EmergencyContactFirstName"],
      "emergency_contact_middle_name": row["EmergencyContactMiddleName"],
      "emergency_contact_phone": row["EmergencyContactPhone"],
      "pager_beeper_number": row["PagerBeeperNumber"],
      "answering_service_phone_number": row["AnsweringServicePhoneNumber"],
      "cell_phone_number": row["CellPhoneNumber"],
      "pager_beeper_digital_flag": row["PagerBeeperDigitalFlag"],
      "visa_expiration_date": row["VisaExpirationDate"],
      "ethnicity_description": row["EthnicityDescription"],
      "visa_issue_date": row["VisaIssueDate"],
      "ecfmg_expiration_date": row["ECFMGExpirationDate"],
      "work_permit_status": row["WorkPermitStatus"],
      "spouse_middle_name": row["SpouseMiddleName"],
      "state_residence_date": row["StateResidenceDate"],
      "citizenship_country_country_name": row["CitizenshipCountry_CountryName"],
      "marital_status_marital_status_description": row["MaritalStatus_MaritalStatusDescription"],
      "gender_gender_description": row["Gender_GenderDescription"],
      "birth_country_country_name": row["BirthCountry_CountryName"],
      "correspondence_address_type_correspondence_address_type_descrip": row["CorrespondenceAddressType_CorrespondenceAddressTypeDescription"],
      "provider_type_provider_type_abbreviation": row["ProviderType_ProviderTypeAbbreviation"],
      "graduate_type_graduate_type_description": row["GraduateType_GraduateTypeDescription"],
      "nid_country_country_name": row["NIDCountry_CountryName"],
      "attest_date": row["AttestDate"],
      "plan_provider_id": row["PlanProviderID"],
      "last_recredential_date": row["LastRecredentialDate"],
      "next_recredential_date": row["NextRecredentialDate"]
    })
  end
end

