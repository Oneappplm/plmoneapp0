require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy employment records without modifying existing records"
  task import_incremental_legacy_employments: :environment do
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
        "employments_#{timestamp}.csv"
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

    parse_date = lambda do |primary_value, fallback_value = nil|
      primary =
        clean_value.call(primary_value)

      if primary.present?
        begin
          next Date.parse(primary)
        rescue ArgumentError, TypeError
          # Try fallback below.
        end
      end

      fallback =
        clean_value.call(fallback_value)

      next nil if fallback.blank?
      next nil if fallback.casecmp("Present").zero?

      begin
        if fallback.match?(/\A\d{1,2}\/\d{4}\z/)
          month, year =
            fallback.split("/").map(&:to_i)

          next Date.new(year, month, 1)
        end

        Date.parse(fallback)
      rescue ArgumentError, TypeError
        nil
      end
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy Employment Import"
    puts "=" * 100
    puts "Target model: ProviderEmployment"
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
        "employer_name",
        "address",
        "city",
        "state",
        "zip",
        "position",
        "from_date",
        "to_date",
        "present",
        "audit_status",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_employment_id",
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

        employer_name =
          clean_value.call(
            row["PracticeName"]
          )

        address =
          clean_value.call(
            row["Address"]
          )

        suite =
          clean_value.call(
            row["Suite"]
          )

        city =
          clean_value.call(
            row["City"]
          )

        state =
          clean_value.call(
            row["State"]
          )

        zip =
          clean_value.call(
            row["Zip"]
          )

        position =
          clean_value.call(
            row["Position"]
          )

        from_date =
          parse_date.call(
            row["AttendedFrom"],
            row["SourceDateFrom"]
          )

        to_date =
          parse_date.call(
            row["AttendedTo"],
            row["SourceDateTo"]
          )

        present =
          parse_boolean.call(
            row["Present"]
          )

        present = false if present.nil?

        audit_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        comments =
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
            employer_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
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
            employer_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        if employer_name.blank?
          stats[:blank_employer] += 1

          message =
            "Missing employer name"

          puts [
            "SKIP BLANK EMPLOYER",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
            "SKIPPED_BLANK_EMPLOYER",
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
            employer_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
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
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        existing =
          ProviderEmployment
            .where(
              provider_attest_id:
                ppi.provider_attest_id
            )
            .detect do |employment|

            employer_matches =
              normalize_text.call(
                employment.employer_name
              ) == normalize_text.call(
                employer_name
              )

            from_matches =
              employment.from_date&.to_date ==
                from_date

            to_matches =
              employment.to_date&.to_date ==
                to_date

            present_matches =
              employment.present == present

            employer_matches &&
              from_matches &&
              to_matches &&
              present_matches
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing employment found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Employer=#{employer_name}",
            "From=#{from_date.inspect}",
            "To=#{to_date.inspect}",
            "Present=#{present}",
            "EmploymentID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            message
          ]

          next
        end

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          employer_name:
            employer_name,

          address:
            address,

          additional_address:
            suite,

          city:
            city,

          state:
            state,

          zip:
            zip,

          position:
            position,

          title:
            position,

          from_date:
            from_date,

          to_date:
            to_date,

          present:
            present,

          audit_status:
            audit_status,

          comments:
            comments,

          show_on_tickler:
            false
        }

        if apply
          begin
            created_employment = nil

            ProviderEmployment.transaction do
              duplicate =
                ProviderEmployment
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |employment|

                  employer_matches =
                    normalize_text.call(
                      employment.employer_name
                    ) == normalize_text.call(
                      employer_name
                    )

                  from_matches =
                    employment.from_date&.to_date ==
                      from_date

                  to_matches =
                    employment.to_date&.to_date ==
                      to_date

                  present_matches =
                    employment.present == present

                  employer_matches &&
                    from_matches &&
                    to_matches &&
                    present_matches
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "Employment appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  employer_name,
                  "EmploymentID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  employer_name,
                  address,
                  city,
                  state,
                  zip,
                  position,
                  from_date,
                  to_date,
                  present,
                  audit_status,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_employment =
                ProviderEmployment.new(
                  attrs
                )

              created_employment.save!(
                validate: false
              )
            end

            if created_employment&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "Employer=#{employer_name}",
                "From=#{from_date.inspect}",
                "To=#{to_date.inspect}",
                "Present=#{present}",
                "EmploymentID=#{created_employment.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                employer_name,
                address,
                city,
                state,
                zip,
                position,
                from_date,
                to_date,
                present,
                audit_status,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_employment.id,
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
              employer_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              employer_name,
              address,
              city,
              state,
              zip,
              position,
              from_date,
              to_date,
              present,
              audit_status,
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
            "Employer=#{employer_name}",
            "From=#{from_date.inspect}",
            "To=#{to_date.inspect}",
            "Present=#{present}",
            "Position=#{position.inspect}",
            "Status=#{audit_status.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            employer_name,
            address,
            city,
            state,
            zip,
            position,
            from_date,
            to_date,
            present,
            audit_status,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching employment"
          ]
        end
      end
    end

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Target: ProviderEmployment"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing employments skipped: #{stats[:existing]}"
    puts "Blank employers skipped: #{stats[:blank_employer]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end