namespace :data do
  desc "Accurately map tbl_ii data to provider_personal_informations"
  task import_tbl_ii_to_ppi: :environment do
    puts "Starting import from tbl_ii..."

    legacy_rows = ActiveRecord::Base.connection.exec_query("SELECT * FROM tbl_ii")
    imported = 0

    legacy_rows.each do |row|
      ppi = ProviderPersonalInformation.new(
      	caqh_provider_id: row['id'],
      	provider_attest_id: row['id'],
        first_name: row["FirstName"],
        middle_name: row["MiddleName"],
        last_name: row["LastName"],
        suffix: row["Suffix"],
        other_name_flag: row["HavingOtherNameOrNot"],
        birth_date: row["BirthDate"],
        date_of_birth: row["BirthDate"],
        birth_city: row["BirthCity"],
        birth_state: row["BirthState"],
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
        state: row["CredentialState"],
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
        puts "❌ Failed to save row ##{row['tbl_II_ID']}: #{ppi.errors.full_messages.join(', ')}"
      end
    end

    puts "✅ Finished. Imported #{imported}/#{legacy_rows.count} records."
  end
end
