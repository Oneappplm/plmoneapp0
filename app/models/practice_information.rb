class PracticeInformation < ApplicationRecord
  self.primary_key = :provider_practice_id

  belongs_to :provider_attest

  has_many   :practice_accessibilities, foreign_key: :provider_practice_id
  has_many   :practice_associates, foreign_key: :provider_practice_id
  has_many   :practice_associate_other_questions, foreign_key: :provider_practice_id
  has_many   :practice_associate_specialties, foreign_key: :provider_practice_id
  has_many   :practice_business_arrangements, foreign_key: :provider_practice_id
  has_many   :practice_certifications, foreign_key: :provider_practice_id
  has_many   :practice_hours, foreign_key: :provider_practice_id
  has_many   :practice_languages, foreign_key: :provider_practice_id
  has_many   :practice_limitations, foreign_key: :provider_practice_id
  has_many   :practice_other_addresses, foreign_key: :provider_practice_id
  has_many   :practice_other_questions, foreign_key: :provider_practice_id
  has_many   :practice_other_tax_ids, foreign_key: :provider_practice_id
  has_many   :practice_patient_types, foreign_key: :provider_practice_id
  has_many   :practice_phone_coverages, foreign_key: :provider_practice_id
  has_many   :practice_services, foreign_key: :provider_practice_id
  has_many   :practice_specialties, foreign_key: :provider_practice_id
  has_many   :practice_tax_ids, foreign_key: :provider_practice_id

  validates :provider_attest, presence: true

  def assign_attributes_from_csv_row(row)
    self.assign_attributes({
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
  end
end
