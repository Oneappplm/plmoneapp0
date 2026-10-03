require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy practice information without modifying existing records"
  task import_incremental_legacy_practice_informations: :environment do
    file = ENV.fetch("FILE")
    apply = ENV["APPLY"].to_s.downcase == "true"

    abort "File not found: #{file}" unless File.exist?(file)

    allowed_clients =
      ENV.fetch(
        "CLIENTS",
        "CUAN,Primary PartnersCare,Broward Health"
      ).split(",").map(&:strip)

    report_dir =
      Rails.root.join("tmp", "legacy_import_reports")

    FileUtils.mkdir_p(report_dir)

    timestamp =
      Time.current.strftime("%Y%m%d_%H%M%S")

    report_file =
      report_dir.join(
        "practice_informations_#{timestamp}.csv"
      )

    stats = Hash.new(0)

    canonical_encid = lambda do |value|
      value = value.to_s.strip.upcase
      digits = value.gsub(/\D/, "")

      next nil if digits.blank?

      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    clean_value = lambda do |value|
      value = value.to_s.strip

      next nil if value.blank?
      next nil if value.casecmp("NULL").zero?

      value
    end

    normalize_text = lambda do |value|
      value.to_s
           .strip
           .downcase
           .gsub(/\s+/, " ")
    end

    parse_boolean = lambda do |value|
      case value.to_s.strip.downcase
      when "1", "true", "yes", "y", "t"
        true
      when "0", "false", "no", "n", "f"
        false
      else
        nil
      end
    end

    parse_date = lambda do |value|
      value = clean_value.call(value)

      next nil if value.blank?

      begin
        Date.parse(value)
      rescue ArgumentError, TypeError
        nil
      end
    end

    parse_integer = lambda do |value|
      value = clean_value.call(value)

      next nil if value.blank?

      digits = value.gsub(/\D/, "")

      next nil if digits.blank?

      digits.to_i
    end

    duplicate_match = lambda do |practice, attrs|
      normalize_text.call(practice.practice_name) ==
        normalize_text.call(attrs[:practice_name]) &&

        normalize_text.call(practice.address) ==
          normalize_text.call(attrs[:address]) &&

        normalize_text.call(practice.address2) ==
          normalize_text.call(attrs[:address2]) &&

        normalize_text.call(practice.city) ==
          normalize_text.call(attrs[:city]) &&

        normalize_text.call(practice.zip) ==
          normalize_text.call(attrs[:zip])
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy Practice Information Import"
    puts "=" * 100
    puts "Target model: PracticeInformation"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"
    puts "File: #{file}"
    puts "Allowed clients: #{allowed_clients.join(', ')}"
    puts "Report: #{report_file}"
    puts "=" * 100
    puts

    CSV.open(report_file, "w") do |report|
      report << [
        "client",
        "encid",
        "provider_name",
        "practice_name",
        "address",
        "address2",
        "city",
        "state",
        "zip",
        "phone",
        "federal_tax_id",
        "group_npi",
        "primary_location",
        "action",
        "ppi_id",
        "provider_attest_id",
        "practice_information_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        next if row["ENCID"].to_s.strip.start_with?("-")

        client =
          row["ClientName"].to_s.strip

        encid =
          canonical_encid.call(
            row["ENCID"]
          )

        practice_name =
          clean_value.call(
            row["PracticeOfficeName"]
          )

        department_name =
          clean_value.call(
            row["DeptName"]
          )

        address =
          clean_value.call(
            row["OfficeAddress"]
          )

        office_suite =
          clean_value.call(
            row["OfficeSuite"]
          )

        additional_address =
          clean_value.call(
            row["OfficeAdditionalAddress"]
          )

        address2 =
          [office_suite, additional_address]
            .compact
            .reject(&:blank?)
            .join(" ")
            .presence

        city =
          clean_value.call(
            row["OfficeCity"]
          )

        county =
          clean_value.call(
            row["OfficeCounty"]
          )

        state =
          clean_value.call(
            row["OfficeState"]
          )

        zip =
          clean_value.call(
            row["OfficeZip"]
          )

        phone =
          clean_value.call(
            row["OfficePhone"]
          )

        email =
          clean_value.call(
            row["OfficeEmail"]
          )

        fax =
          clean_value.call(
            row["OfficeFax"]
          )

        country =
          clean_value.call(
            row["OfficeCountry"]
          )

        group_name =
          clean_value.call(
            row["GroupCorporateName"]
          )

        tax_name =
          clean_value.call(
            row["FedTaxIDName"]
          )

        federal_tax_id =
          clean_value.call(
            row["FedTaxID"]
          )

        group_npi =
          parse_integer.call(
            row["GroupNPI"]
          )

        start_date =
          parse_date.call(
            row["DateJoined"]
          )

        is_primary_location =
          parse_boolean.call(
            row["PrimaryOffice"]
          )

        office_manager =
          clean_value.call(
            row["OfficeManagerName"]
          )

        manager_phone =
          clean_value.call(
            row["OfficeManagerPhone"]
          )

        manager_fax =
          clean_value.call(
            row["OfficeManagerFax"]
          )

        comment =
          clean_value.call(
            row["Comments"]
          )

        unless allowed_clients.include?(client)
          stats[:unsupported_client] += 1

          message =
            "Unsupported client: #{client.inspect}"

          puts [
            "SKIP CLIENT",
            encid,
            practice_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_CLIENT",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        if encid.blank?
          stats[:invalid_encid] += 1

          message =
            "Missing or invalid ENCID"

          puts [
            "SKIP INVALID ENCID",
            practice_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        if practice_name.blank?
          stats[:blank_practice] += 1

          message =
            "Missing PracticeOfficeName"

          puts [
            "SKIP BLANK PRACTICE",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_BLANK_PRACTICE",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        ppi =
          ProviderPersonalInformation.find_by(
            encompass_id_text: encid
          )

        unless ppi
          stats[:missing_provider] += 1

          message =
            "Provider not found for ENCID"

          puts [
            "SKIP MISSING PROVIDER",
            encid,
            practice_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_MISSING_PROVIDER",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        provider_name =
          [
            ppi.first_name,
            ppi.middle_name,
            ppi.last_name
          ].compact.join(" ")

        if ppi.legacy_client_name.present? &&
           ppi.legacy_client_name != client

          stats[:client_mismatch] += 1

          message =
            "Source client #{client.inspect} does not match provider client #{ppi.legacy_client_name.inspect}"

          puts [
            "SKIP CLIENT MISMATCH",
            encid,
            provider_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          practice_name:
            practice_name,

          department_name:
            department_name,

          address:
            address,

          address2:
            address2,

          city:
            city,

          county:
            county,

          state:
            state,

          zip:
            zip,

          phone_number:
            phone,

          email_address:
            email,

          fax_number:
            fax,

          country:
            country,

          group_name:
            group_name,

          name_affiliated_with_tax_id:
            tax_name,

          federal_tax_id:
            federal_tax_id,

          group_npi:
            group_npi,

          start_date:
            start_date,

          is_primary_location:
            is_primary_location,

          office_manager:
            office_manager,

          manager_phone_number:
            manager_phone,

          manager_fax_number:
            manager_fax,

          comment:
            comment
        }

        existing =
          PracticeInformation
            .where(
              provider_attest_id:
                ppi.provider_attest_id
            )
            .detect do |practice|

            duplicate_match.call(
              practice,
              attrs
            )
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing practice information found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Practice=#{practice_name}",
            "Address=#{address.inspect}",
            "City=#{city.inspect}",
            "Zip=#{zip.inspect}",
            "PracticeID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            message
          ]

          next
        end

        if apply
          begin
            created_practice = nil

            PracticeInformation.transaction do
              duplicate =
                PracticeInformation
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |practice|

                  duplicate_match.call(
                    practice,
                    attrs
                  )
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "Practice appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  practice_name,
                  "PracticeID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  practice_name,
                  address,
                  address2,
                  city,
                  state,
                  zip,
                  phone,
                  federal_tax_id,
                  group_npi,
                  is_primary_location,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_practice =
                PracticeInformation.new(
                  attrs
                )

              created_practice.save!(
                validate: false
              )
            end

            if created_practice&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "Practice=#{practice_name}",
                "Address=#{address.inspect}",
                "City=#{city.inspect}",
                "State=#{state.inspect}",
                "Zip=#{zip.inspect}",
                "Primary=#{is_primary_location.inspect}",
                "PracticeID=#{created_practice.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                practice_name,
                address,
                address2,
                city,
                state,
                zip,
                phone,
                federal_tax_id,
                group_npi,
                is_primary_location,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_practice.id,
                "Created successfully"
              ]
            end

          rescue => e
            stats[:errors] += 1

            message =
              "#{e.class}: #{e.message}"

            puts [
              "ERROR",
              encid,
              practice_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              practice_name,
              address,
              address2,
              city,
              state,
              zip,
              phone,
              federal_tax_id,
              group_npi,
              is_primary_location,
              "ERROR",
              ppi.id,
              ppi.provider_attest_id,
              nil,
              message
            ]
          end

        else
          stats[:would_create] += 1

          puts [
            "WOULD_CREATE",
            encid,
            provider_name,
            "Practice=#{practice_name}",
            "Address=#{address.inspect}",
            "City=#{city.inspect}",
            "State=#{state.inspect}",
            "Zip=#{zip.inspect}",
            "Primary=#{is_primary_location.inspect}",
            "TaxID=#{federal_tax_id.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            practice_name,
            address,
            address2,
            city,
            state,
            zip,
            phone,
            federal_tax_id,
            group_npi,
            is_primary_location,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching practice information"
          ]
        end
      end
    end

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Target: PracticeInformation"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing practices skipped: #{stats[:existing]}"
    puts "Blank practices skipped: #{stats[:blank_practice]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end