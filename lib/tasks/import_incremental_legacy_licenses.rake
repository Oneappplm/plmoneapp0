require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy provider licenses without modifying existing license records"
  task import_incremental_legacy_licenses: :environment do
    file = ENV.fetch("FILE")
    apply = ENV["APPLY"].to_s.downcase == "true"

    unless File.exist?(file)
      abort "File not found: #{file}"
    end

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
      report_dir.join("licenses_#{timestamp}.csv")

    stats = Hash.new(0)

    normalize_encid = lambda do |value|
      value = value.to_s.strip.upcase
      digits = value.gsub(/\D/, "")

      next nil if digits.blank?

      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    normalize_license_number = lambda do |value|
      value.to_s.strip.upcase.gsub(/\s+/, "")
    end

    parse_date = lambda do |value|
      value = value.to_s.strip

      next nil if value.blank? ||
                  value.casecmp("NULL").zero?

      begin
        Date.parse(value)
      rescue ArgumentError, TypeError
        nil
      end
    end

    parse_boolean = lambda do |value|
      value = value.to_s.strip.downcase

      case value
      when "1", "true", "yes", "y"
        true
      when "0", "false", "no", "n"
        false
      else
        nil
      end
    end

    clean_value = lambda do |value|
      value = value.to_s.strip

      next nil if value.blank? ||
                  value.casecmp("NULL").zero?

      value
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy License Import"
    puts "=" * 100
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
        "license_number",
        "state",
        "state_id",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_licensure_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        #
        # sqlcmd produces a separator line:
        #
        # -----|----------|...
        #
        next if row["ENCID"].to_s.strip.start_with?("-")

        client =
          row["ClientName"].to_s.strip

        encid =
          normalize_encid.call(row["ENCID"])

        license_number =
          clean_value.call(row["LicenseNumber"])

        state_code =
          clean_value.call(row["State"])&.upcase

        if client.blank? ||
           !allowed_clients.include?(client)

          stats[:unsupported_client] += 1

          message =
            "Unsupported client: #{client.inspect}"

          puts [
            "SKIP CLIENT",
            encid,
            license_number,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            license_number,
            state_code,
            nil,
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
            license_number,
            client
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            license_number,
            state_code,
            nil,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        if license_number.blank?
          stats[:invalid_license] += 1

          message =
            "Missing license number"

          puts [
            "SKIP INVALID LICENSE",
            encid,
            client
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            state_code,
            nil,
            "SKIPPED_INVALID_LICENSE",
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
            license_number
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            license_number,
            state_code,
            nil,
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
            license_number,
            state_code,
            nil,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        state =
          if state_code.present?
            State.find_by(
              "UPPER(alpha_code) = ?",
              state_code
            )
          end

        unless state
          stats[:unknown_state] += 1

          message =
            "Unknown state: #{state_code.inspect}"

          puts [
            "SKIP UNKNOWN STATE",
            encid,
            license_number,
            state_code
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            license_number,
            state_code,
            nil,
            "SKIPPED_UNKNOWN_STATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        normalized_number =
          normalize_license_number.call(
            license_number
          )

        existing =
          ProviderLicensure
            .where(
              provider_attest_id:
                ppi.provider_attest_id,
              state_id:
                state.id
            )
            .detect do |license|

            normalize_license_number.call(
              license.license_number
            ) == normalized_number
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing license found; record left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "License=#{license_number}",
            "State=#{state.alpha_code}",
            "LicensureID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            license_number,
            state.alpha_code,
            state.id,
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

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          license_number:
            license_number,

          state_id:
            state.id,

          license_issue_date:
            parse_date.call(
              row["IssueDate"]
            ),

          license_expiration_date:
            parse_date.call(
              row["ExpirationDate"]
            ),

          currently_practice_under_this:
            parse_boolean.call(
              row["CurrentlyPractice"]
            ),

          is_primary_license:
            parse_boolean.call(
              row["PrimaryLicense"]
            ),

          level_require_supervision:
            parse_boolean.call(
              row["LicenseRequireSupervision"]
            ),

          license_comment:
            clean_value.call(
              row["ListComments"]
            ),

          audit_status:
            clean_value.call(
              row["LicenseStatus"]
            ),

          show_on_tickler:
            parse_boolean.call(
              row["ShowOnTickler"]
            ),

          failed_state_license_exam:
            parse_boolean.call(
              row["LicenseFailed"]
            )
        }

        if apply
          begin
            created_license = nil

            ProviderLicensure.transaction do
              #
              # Recheck immediately before insert.
              #
              duplicate =
                ProviderLicensure
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id,
                    state_id:
                      state.id
                  )
                  .detect do |license|

                  normalize_license_number.call(
                    license.license_number
                  ) == normalized_number
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "License appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  license_number,
                  "LicensureID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  license_number,
                  state.alpha_code,
                  state.id,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_license =
                ProviderLicensure.new(attrs)

              created_license.save!(
                validate: false
              )
            end

            if created_license&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "License=#{license_number}",
                "State=#{state.alpha_code}",
                "LicensureID=#{created_license.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                license_number,
                state.alpha_code,
                state.id,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_license.id,
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
              license_number,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              license_number,
              state.alpha_code,
              state.id,
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
            "License=#{license_number}",
            "State=#{state.alpha_code}(#{state.id})",
            "Issue=#{attrs[:license_issue_date]}",
            "Expiration=#{attrs[:license_expiration_date]}",
            "Status=#{attrs[:audit_status].inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            license_number,
            state.alpha_code,
            state.id,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching license"
          ]
        end
      end
    end

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing licenses skipped: #{stats[:existing]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unknown states: #{stats[:unknown_state]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Invalid license number: #{stats[:invalid_license]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end
