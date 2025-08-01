# class TblIi < ApplicationRecord
# 	self.table_name = "tbl_ii"
# 	self.primary_key = "id"

# 	 ransacker :name_or_attest_id do
#     Arel.sql("
#       CONCAT_WS(' ',
#         COALESCE(\"FirstName\", ''),
#         COALESCE(\"LastName\", ''),
#         COALESCE(id::text, '')
#       )
#     ")
#   end

#   def self.ransackable_attributes(auth_object = nil)
#     ["AdditionalPractitionerType", "AlienRegisNum", "AlliedProfessional", "AvailabilityForCall", "BirthCity", "BirthCountry", "BirthDate", "BirthState", "Comments", "ConfAdditionalAddress", "ConfAddress", "ConfCity", "ConfContactFirstName", "ConfContactLastName", "ConfContactMethod", "ConfContactSuffix", "ConfContactTitle", "ConfCountry", "ConfCounty", "ConfEmail", "ConfFax", "ConfMobilePhone", "ConfPhone", "ConfState", "ConfSuite", "ConfZip", "ContactMethod", "CountryOfCitizenship", "CredentialAdditionalAddress", "CredentialAddress", "CredentialCity", "CredentialContactFirstName", "CredentialContactLastName", "CredentialContactMethod", "CredentialContactSuffix", "CredentialContactTitle", "CredentialCountry", "CredentialCounty", "CredentialEmail", "CredentialFax", "CredentialMobilePhone", "CredentialPhone", "CredentialState", "CredentialSuite", "CredentialZip", "CustomID1", "CustomID2", "CustomID3", "DateCreated", "DiagnosticPharAgent", "Eligible", "Email", "Ethnicity", "Fax", "FedEmployeeID", "FirstName", "FloridaID", "Gender", "HavingOtherNameOrNot", "HomeFax", "HomePhone", "LastName", "MakeHouseCallsOrNot", "MaritalStatus", "MiddleName", "Mkt", "OcularPharAgent", "OtherAreas", "PersonalEmail", "Phone", "PracID", "PracticingSpecialty", "PractitionerGUID", "PractitionerSignatory", "PractitionerType", "PractitionerTypeOther", "PriCarePractitioner", "PriSpecialty", "QualityAuditComplete", "Religion", "RelocateOrNot", "RelocationDate", "SSN", "SecSpecialty", "SpeciaList", "Specialty1", "Specialty2", "Specialty3", "Specialty4", "Specialty5", "SpouseFirstName", "SpouseLastName", "SpouseMiddleName", "Suffix", "TerSpecialty", "TherapeuticPharAgent", "Title", "USCitizenOrNot", "VerificationCompleteDate", "VisaNumber", "VisaStatus", "WebPages", "id", "name_or_id", "tbl_II_ID", "tbl_InsTable_HomeAddress_ID", "tbl_InsTable_OtherName_ID"]
#   end

#   def self.ransackable_associations(auth_object = nil)
#     []
#   end

# end

