require 'csv'

namespace :data do
  desc "Import provider_personal_informations from tbl_ii CSV"
  task import_tbl_ii_csv: :environment do
    file_path = Rails.root.join("public", "tbl_II_202508021611.csv")
    puts "📂 Importing from #{file_path}..."

    imported = 0
    total = 0

    CSV.foreach(file_path, headers: true) do |row|
      total += 1

      # ✅ Don't touch id, use caqh_provider_attest_id for mapping
      attest = ProviderAttest.find_or_initialize_by(caqh_provider_attest_id: row['PracID'])
      attest.save! if attest.new_record?

      # Map birth_state via states table
      debugger
      birth_state_record = State.find_by(alpha_code: row["BirthState"])
      birth_state_id = birth_state_record&.id
      puts "⚠️ Birth state not found: #{row['BirthState']}" unless birth_state_id

      # Map provider state via states table
      state_record = State.find_by(alpha_code: row["CredentialState"])
      state_id = state_record&.id
      puts "⚠️ Provider state not found: #{row['CredentialState']}" unless state_id

      ppi = ProviderPersonalInformation.new(
        practitioner_guid: row['PractitionerGUID'],
        caqh_provider_id: row['id'],
        provider_attest_id: attest.id, # real FK
        caqh_provider_attest_id: attest.caqh_provider_attest_id,
        first_name: row["FirstName"],
        middle_name: row["MiddleName"],
        last_name: row["LastName"],
        suffix: row["Suffix"],
        other_name_flag: row["HavingOtherNameOrNot"],
        birth_date: row["BirthDate"],
        date_of_birth: row["BirthDate"],
        birth_city: row["BirthCity"],
        birth_state: birth_state_id,
        birth_country_country_name: row["BirthCountry"],
        us_eligible_flag: row["Eligible"],
        citizenship_country_country_name: row["CountryOfCitizenship"],
        visa_status: row["VisaStatus"],
        visa_number: row["VisaNumber"],
        federal_employee_id: row["FedEmployeeID"],
        ssn: row["SSN"],
        practitioner_type: row["PractitionerType"],
        ethnicity_description: row["Ethnicity"],
        gender: row["Gender"],
        email_address: row["Email"],
        fax_number: row["Fax"],
        telephone_number: row["Phone"],
        cell_phone_number: row["CredentialMobilePhone"],
        availability: row["AvailabilityForCall"],
        market: row["Mkt"],
        spouse_first_name: row["SpouseFirstName"],
        spouse_middle_name: row["SpouseMiddleName"],
        spouse_last_name: row["SpouseLastName"],
        marital_status_marital_status_description: row["MaritalStatus"],
        address_line1: row["CredentialAddress"],
        address_line2: row["CredentialAdditionalAddress"],
        city: row["CredentialCity"],
        state: state_id,
        zipcode: row["CredentialZip"],
        country: row["CredentialCountry"],
        county: row["CredentialCounty"],
        emergency_contact_first_name: row["ConfContactFirstName"],
        emergency_contact_last_name: row["ConfContactLastName"],
        emergency_contact_phone: row["ConfPhone"],
        pager_beeper_number: row["ConfMobilePhone"]
      )

      if ppi.save(validate: false)
        imported += 1
      else
        puts "❌ Failed row #{total}: #{ppi.errors.full_messages.join(', ')}"
      end
    end

    puts "✅ Finished. Imported #{imported}/#{total} records."
  end
end
