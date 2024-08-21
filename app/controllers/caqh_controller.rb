class CaqhController < ApplicationController
  protect_from_forgery with: :null_session

  def show
  end

  def upload
    ActiveRecord::Base.transaction do
      update_or_create_provider_personal_informations
      update_or_create_practice_information
    end
    head :ok
  end

  private
  def update_or_create_provider_personal_informations
    file = File.read(params[:ProviderPersonalInformation])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      provider_attest = ProviderAttest.find_or_create_by(provider_attest_id: row["ProviderAttestID"])

      provider_personal_information = ProviderPersonalInformation.find_or_initialize_by({
        "provider_id": row["ProviderID"],
        "provider_attest_id": provider_attest.id
      })
      provider_personal_information.assign_attributes({
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

      provider_personal_information.save!
    end
  end

  def update_or_create_practice_information
    file = File.read(params[:PracticeInformation])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      provider_attest = ProviderAttest.find_or_create_by(provider_attest_id: row["ProviderAttestID"])

      practice_information = PracticeInformation.find_or_initialize_by({
        "provider_practice_id": row["ProviderPracticeID"],
        "provider_attest_id": provider_attest.id
      })
      practice_information.assign_attributes({
        "practice_name": row["PracticeName"],
        "address": row["Address"],
        "address2": row["Address2"],
        "city": row["City"],
        "state": row["State"],
        "zip": row["Zip"],
        "ext_zip": row["ExtZip"],
        "county": row["County"],
        "phone_number": row["PhoneNumber"],
        "after_hours_phone_number": row["AfterHoursPhoneNumber"],
        "fax_number": row["FaxNumber"],
        "email_address": row["EmailAddress"],
        "correspondence_flag": row["CorrespondenceFlag"],
        "partners_flag": row["PartnersFlag"],
        "other_associates_flag": row["OtherAssociatesFlag"],
        "currently_practicing_flag": row["CurrentlyPracticingFlag"],
        "start_date": row["StartDate"],
        "coverage24x7_flag": row["Coverage24x7Flag"],
        "practice_limitation_flag": row["PracticeLimitationFlag"],
        "ada_approved_flag": row["ADAApprovedFlag"],
        "minority_business_flag": row["MinorityBusinessFlag"],
        "interpreter_available_flag": row["InterpreterAvailableFlag"],
        "medicare_number": row["MedicareNumber"],
        "medicaid_number": row["MedicaidNumber"],
        "epsdt_certified_flag": row["EPSDTCertifiedFlag"],
        "epsdt_number": row["EPSDTNumber"],
        "practice_organization_type": row["PracticeOrganizationType"],
        "phone_number2": row["PhoneNumber2"],
        "patient_appointment_phone_number": row["PatientAppointmentPhoneNumber"],
        "answering_service_phone_number": row["AnsweringServicePhoneNumber"],
        "pager_beeper_number": row["PagerBeeperNumber"],
        "list_in_directory_flag": row["ListInDirectoryFlag"],
        "w9_practice_name": row["W9PracticeName"],
        "in_practice_flag": row["InPracticeFlag"],
        "practice_intention_explanation": row["PracticeIntentionExplanation"],
        "emergency_phone_number": row["EmergencyPhoneNumber"],
        "practice_description": row["PracticeDescription"],
        "patients_enrolled": row["PatientsEnrolled"],
        "patient_visits": row["PatientVisits"],
        "appointments_per_hour": row["AppointmentsPerHour"],
        "average_waiting_time": row["AverageWaitingTime"],
        "call_response_time": row["CallResponseTime"],
        "electronic_billing_flag": row["ElectronicBillingFlag"],
        "bwc_number": row["BWCNumber"],
        "workers_compensation_risk_number": row["WorkersCompensationRiskNumber"],
        "ownership_description": row["OwnershipDescription"],
        "emergency_procedure": row["EmergencyProcedure"],
        "npi": row["NPI"],
        "practice_type_description": row["PracticeTypeDescription"],
        "service_type_description": row["ServiceTypeDescription"],
        "department_name": row["DepartmentName"],
        "cell_phone_number": row["CellPhoneNumber"],
        "pager_beeper_number2": row["PagerBeeperNumber2"],
        "end_date": row["EndDate"],
        "phone_extension": row["PhoneExtension"],
        "patient_appointment_phone_extension": row["PatientAppointmentPhoneExtension"],
        "answering_service_phone_extension": row["AnsweringServicePhoneExtension"],
        "correspondence_method": row["CorrespondenceMethod"],
        "address_type_address_type_description": row["AddressType_AddressTypeDescription"]
      })

      practice_information.save!
    end
  end

  # def client_organization_params
  #   params.require(:client_organization).permit(:organization_name, :organization_type, :organization_npi, :organization_address_1, :organization_address_2, :organization_city, :organization_state_id, :organization_zipcode, :organization_phone_number, :organization_fax_number, :organization_dba_name, :organization_tax_id)
  # end
end
