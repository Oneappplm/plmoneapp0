require "csv"
require "fileutils"

namespace :legacy do
  desc "Incrementally import legacy DEA records without modifying existing records"
  task import_incremental_legacy_deas: :environment do
    file = ENV.fetch("FILE")
    apply = ENV["APPLY"].to_s.downcase == "true"

    abort "File not found: #{file}" unless File.exist?(file)

    allowed_clients =
      ENV.fetch(
        "CLIENTS",
        "CUAN,Primary PartnersCare,Broward Health"
      ).split(",").map(&:strip)

    report_dir =
      Rails.root.join(
        "tmp",
        "legacy_import_reports"
      )

    FileUtils.mkdir_p(report_dir)

    timestamp =
      Time.current.strftime("%Y%m%d_%H%M%S")

    report_file =
      report_dir.join(
        "deas_#{timestamp}.csv"
      )

    stats = Hash.new(0)

    model = ProviderDea
    model_columns = model.column_names

    # ---------------------------------------------------------
    # Helpers
    # ---------------------------------------------------------

    clean_value = lambda do |value|
      value = value.to_s.strip

      next nil if value.blank?
      next nil if value.casecmp("NULL").zero?

      value
    end

    canonical_encid = lambda do |value|
      value = clean_value.call(value)

      next nil if value.blank?

      value = value.upcase

      if value.match?(/\AENC\d+\z/)
        digits = value.delete_prefix("ENC")

        next "ENC#{digits.to_i.to_s.rjust(6, "0")}"
      end

      digits = value.gsub(/\D/, "")

      next nil if digits.blank?

      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    parse_boolean = lambda do |value|
      value = clean_value.call(value)

      next nil if value.nil?

      case value.to_s.downcase
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

    filter_attributes = lambda do |attrs|
      attrs.select do |key, _value|
        model_columns.include?(key.to_s)
      end
    end

    normalized_dea = lambda do |value|
      clean_value.call(value)
        .to_s
        .upcase
        .gsub(/\s+/, "")
    end

    build_schedules = lambda do |row|
      full_schedule =
        parse_boolean.call(
          row["FullSchedule"]
        )

      if full_schedule
        next ["2", "2N", "3", "3N", "4", "5"]
      end

      schedules = []

      schedules << "2" if parse_boolean.call(row["Schedule2"])
      schedules << "2N" if parse_boolean.call(row["Schedule2N"])
      schedules << "3" if parse_boolean.call(row["Schedule3"])
      schedules << "3N" if parse_boolean.call(row["Schedule3N"])
      schedules << "4" if parse_boolean.call(row["Schedule4"])
      schedules << "5" if parse_boolean.call(row["Schedule5"])

      schedules
    end

    # ---------------------------------------------------------
    # Header
    # ---------------------------------------------------------

    puts
    puts "=" * 100
    puts "Incremental Legacy DEA Import"
    puts "=" * 100
    puts "Target model: ProviderDea"
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
        "dea_number",
        "state",
        "issue_date",
        "expiration_date",
        "full_schedule",
        "schedules_held",
        "limited",
        "limited_explanation",
        "show_on_tickler",
        "quality_audit_complete",
        "verified_status",
        "dea_status",
        "verified_source",
        "source_dea_guid",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_dea_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        # sqlcmd separator line
        next if row["ENCID"].to_s.strip.start_with?("-")

        # -----------------------------------------------------
        # Source values
        # -----------------------------------------------------

        encid =
          canonical_encid.call(
            row["ENCID"]
          )

        client =
          clean_value.call(
            row["ClientName"]
          )

        dea_number =
          clean_value.call(
            row["DEANumber"]
          )

        state =
          clean_value.call(
            row["State"]
          )

        issue_date =
          parse_date.call(
            row["IssueDate"]
          )

        expiration_date =
          parse_date.call(
            row["ExpirationDate"]
          )

        full_schedule =
          parse_boolean.call(
            row["FullSchedule"]
          )

        schedules_held =
          build_schedules.call(row)

        limited =
          parse_boolean.call(
            row["Limited"]
          )

        limited_explanation =
          clean_value.call(
            row["LimitedExplanation"]
          )

        show_on_tickler =
          parse_boolean.call(
            row["ShowOnTickler"]
          )

        quality_audit =
          clean_value.call(
            row["DEAQualityAuditComplete"]
          )

        verified_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        dea_status =
          clean_value.call(
            row["DEAStatus"]
          )

        verified_source =
          clean_value.call(
            row["VerifiedSource"]
          )

        source_guid =
          clean_value.call(
            row["SourceDEAGUID"]
          )

        # -----------------------------------------------------
        # Validate client
        # -----------------------------------------------------

        unless allowed_clients.include?(client)
          stats[:unsupported_client] += 1

          message =
            "Unsupported client: #{client.inspect}"

          puts [
            "SKIP CLIENT",
            encid,
            "DEA=#{dea_number.inspect}",
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "SKIPPED_CLIENT",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Validate ENCID
        # -----------------------------------------------------

        if encid.blank?
          stats[:invalid_encid] += 1

          message = "Missing or invalid ENCID"

          puts [
            "SKIP INVALID ENCID",
            "DEA=#{dea_number.inspect}"
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Validate DEA number
        # -----------------------------------------------------

        if dea_number.blank?
          stats[:invalid_dea] += 1

          message = "Missing DEA number"

          puts [
            "SKIP INVALID DEA",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "SKIPPED_INVALID_DEA",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Find target provider
        # -----------------------------------------------------

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
            "DEA=#{dea_number}"
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
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

        # -----------------------------------------------------
        # Client ownership validation
        # -----------------------------------------------------

        if ppi.legacy_client_name.present? &&
           ppi.legacy_client_name != client

          stats[:client_mismatch] += 1

          message =
            "Source client #{client.inspect} does not match provider client #{ppi.legacy_client_name.inspect}"

          puts [
            "SKIP CLIENT MISMATCH",
            encid,
            provider_name,
            "DEA=#{dea_number}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Build target attributes
        # -----------------------------------------------------

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          dea_number:
            dea_number,

          state:
            state,

          application_date:
            issue_date,

          expiration_date:
            expiration_date,

          full_schedule:
            full_schedule ? "Yes" : "No",

          schedules_held:
            schedules_held,

          dea_license_limitation_flag:
            limited,

          dea_license_limitation_explanation:
            limited_explanation,

          show_on_tickler:
            show_on_tickler
        }

        attrs =
          filter_attributes.call(attrs)

        # -----------------------------------------------------
        # Duplicate protection
        # provider + DEA number
        # -----------------------------------------------------

        existing =
          model
            .where(
              provider_attest_id:
                ppi.provider_attest_id
            )
            .detect do |record|

            normalized_dea.call(
              record.dea_number
            ) ==
              normalized_dea.call(
                dea_number
              )
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing DEA found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "DEA=#{dea_number}",
            "State=#{state.inspect}",
            "DEAID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # APPLY
        # -----------------------------------------------------

        if apply
          begin
            created_record = nil
            duplicate_during_apply = nil

            model.transaction do
              duplicate_during_apply =
                model
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |record|

                  normalized_dea.call(
                    record.dea_number
                  ) ==
                    normalized_dea.call(
                      dea_number
                    )
                end

              unless duplicate_during_apply
                created_record =
                  model.new(attrs)

                created_record.save!(
                  validate: false
                )
              end
            end

            if duplicate_during_apply
              stats[:existing] += 1

              message =
                "Record appeared before create; left unchanged"

              puts [
                "SKIP EXISTING",
                encid,
                "DEA=#{dea_number}",
                "DEAID=#{duplicate_during_apply.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                dea_number,
                state,
                issue_date,
                expiration_date,
                full_schedule,
                schedules_held.join(","),
                limited,
                limited_explanation,
                show_on_tickler,
                quality_audit,
                verified_status,
                dea_status,
                verified_source,
                source_guid,
                "SKIPPED_EXISTING",
                ppi.id,
                ppi.provider_attest_id,
                duplicate_during_apply.id,
                message
              ]

              next
            end

            if created_record&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "DEA=#{dea_number}",
                "State=#{state.inspect}",
                "Issue=#{issue_date.inspect}",
                "Expiration=#{expiration_date.inspect}",
                "FullSchedule=#{full_schedule.inspect}",
                "Schedules=#{schedules_held.inspect}",
                "Limited=#{limited.inspect}",
                "DEAID=#{created_record.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                dea_number,
                state,
                issue_date,
                expiration_date,
                full_schedule,
                schedules_held.join(","),
                limited,
                limited_explanation,
                show_on_tickler,
                quality_audit,
                verified_status,
                dea_status,
                verified_source,
                source_guid,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_record.id,
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
              provider_name,
              "DEA=#{dea_number}",
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              dea_number,
              state,
              issue_date,
              expiration_date,
              full_schedule,
              schedules_held.join(","),
              limited,
              limited_explanation,
              show_on_tickler,
              quality_audit,
              verified_status,
              dea_status,
              verified_source,
              source_guid,
              "ERROR",
              ppi.id,
              ppi.provider_attest_id,
              nil,
              message
            ]
          end

        # -----------------------------------------------------
        # DRY RUN
        # -----------------------------------------------------

        else
          stats[:would_create] += 1

          puts [
            "WOULD_CREATE",
            encid,
            provider_name,
            "DEA=#{dea_number}",
            "State=#{state.inspect}",
            "Issue=#{issue_date.inspect}",
            "Expiration=#{expiration_date.inspect}",
            "FullSchedule=#{full_schedule.inspect}",
            "Schedules=#{schedules_held.inspect}",
            "Limited=#{limited.inspect}",
            "Tickler=#{show_on_tickler.inspect}",
            "Verified=#{verified_status.inspect}",
            "Status=#{dea_status.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            dea_number,
            state,
            issue_date,
            expiration_date,
            full_schedule,
            schedules_held.join(","),
            limited,
            limited_explanation,
            show_on_tickler,
            quality_audit,
            verified_status,
            dea_status,
            verified_source,
            source_guid,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching DEA record"
          ]
        end
      end
    end

    # ---------------------------------------------------------
    # Summary
    # ---------------------------------------------------------

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Target: ProviderDea"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing DEAs skipped: #{stats[:existing]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Invalid DEA numbers: #{stats[:invalid_dea]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end