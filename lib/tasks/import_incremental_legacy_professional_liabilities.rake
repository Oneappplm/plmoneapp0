require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy professional liability records without modifying existing records"
  task import_incremental_legacy_professional_liabilities: :environment do
    file  = ENV.fetch("FILE")
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
        "professional_liabilities_#{timestamp}.csv"
      )

    stats = Hash.new(0)

    # ---------------------------------------------------------
    # Helpers
    # ---------------------------------------------------------

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

    boolean_string = lambda do |value|
      parsed = parse_boolean.call(value)

      next nil if parsed.nil?

      parsed ? "1" : "0"
    end

    parse_date = lambda do |value|
      value = clean_value.call(value)

      next nil if value.blank?

      begin
        if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
          Date.strptime(value, "%Y-%m-%d")
        elsif value.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
          Date.strptime(value, "%m/%d/%Y")
        else
          Date.parse(value)
        end
      rescue ArgumentError, TypeError
        nil
      end
    end

    # Duplicate identity:
    #
    # provider +
    # carrier +
    # policy +
    # effective/start date +
    # expiration/end date
    #
    # This intentionally does NOT update any existing row.
    duplicate_match = lambda do |record, attrs|
      carrier_matches =
        normalize_text.call(record.insurance_carrier_name) ==
          normalize_text.call(attrs[:insurance_carrier_name])

      policy_matches =
        normalize_text.call(record.policy_number) ==
          normalize_text.call(attrs[:policy_number])

      start_matches =
        record.original_start_date&.to_date ==
          attrs[:original_start_date]

      end_matches =
        record.end_date&.to_date ==
          attrs[:end_date]

      carrier_matches &&
        policy_matches &&
        start_matches &&
        end_matches
    end

    # ---------------------------------------------------------
    # Header
    # ---------------------------------------------------------

    puts
    puts "=" * 100
    puts "Incremental Legacy Professional Liability Import"
    puts "=" * 100
    puts "Target model: ProviderInsuranceCoverage"
    puts "form_type: main"
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
        "carrier",
        "policy_holder",
        "policy_number",
        "effective_date",
        "expiration_date",
        "occurrence_amount",
        "aggregate_amount",
        "does_not_expire",
        "verified_status",
        "verified_source",
        "source_tbl_xii_id",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_insurance_coverage_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        # sqlcmd separator:
        # -----|-----|...
        next if row["ENCID"].to_s.strip.start_with?("-")

        client =
          clean_value.call(
            row["ClientName"]
          )

        encid =
          canonical_encid.call(
            row["ENCID"]
          )

        carrier_name =
          clean_value.call(
            row["CarrierName"]
          )

        policy_holder =
          clean_value.call(
            row["PolicyHolder"]
          )

        policy_number =
          clean_value.call(
            row["PolicyNumber"]
          )

        original_start_date =
          parse_date.call(
            row["OriginalEffectiveDate"]
          )

        expiration_date =
          parse_date.call(
            row["ExpirationDate"]
          )

        occurrence_amount =
          clean_value.call(
            row["OccurrenceAmount"]
          )

        aggregate_amount =
          clean_value.call(
            row["AggregateAmount"]
          )

        umbrella_amount =
          clean_value.call(
            row["UmbrellaCoverageAmount"]
          )

        self_insured =
          parse_boolean.call(
            row["SelfInsured"]
          )

        individual_coverage =
          parse_boolean.call(
            row["Coverage"]
          )

        carrier_excluded =
          parse_boolean.call(
            row["CurCarrierExcludePractice"]
          )

        exclusions =
          clean_value.call(
            row["ListExclusions"]
          )

        carrier_phone =
          clean_value.call(
            row["CarrierPhone"]
          )

        carrier_fax =
          clean_value.call(
            row["CarrierFax"]
          )

        carrier_email =
          clean_value.call(
            row["CarrierEmail"]
          )

        show_on_tickler =
          parse_boolean.call(
            row["ShowOnTickler"]
          )

        does_not_expire =
          parse_boolean.call(
            row["NotExpire"]
          )

        source_comments =
          clean_value.call(
            row["SourceComments"]
          )

        liability_audit =
          boolean_string.call(
            row["LiabCoverageQualityAuditComplete"]
          )

        claims_history_audit =
          boolean_string.call(
            row["ClaimsHistoryQualityAuditComplete"]
          )

        verified_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        verified_source =
          clean_value.call(
            row["VerifiedSource"]
          )

        source_tbl_xii_id =
          clean_value.call(
            row["tbl_XII_ID"]
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
            carrier_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
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

          message =
            "Missing or invalid ENCID"

          puts [
            "SKIP INVALID ENCID",
            carrier_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Carrier required
        # -----------------------------------------------------

        if carrier_name.blank?
          stats[:blank_carrier] += 1

          message =
            "Missing CarrierName"

          puts [
            "SKIP BLANK CARRIER",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
            "SKIPPED_BLANK_CARRIER",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Find provider
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
            carrier_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
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
        # Validate client ownership
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
            message
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        # -----------------------------------------------------
        # Attributes
        # -----------------------------------------------------

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          insurance_carrier_name:
            carrier_name,

          policy_holder:
            policy_holder,

          policy_number:
            policy_number,

          original_start_date:
            original_start_date,

          start_date:
            original_start_date,

          effective_date:
            original_start_date,

          end_date:
            expiration_date,

          coverage_amount_occurrence:
            occurrence_amount,

          coverage_amount_aggregate:
            aggregate_amount,

          umbrella_coverage_amount:
            umbrella_amount,

          self_insured_flag:
            self_insured,

          individual_coverage_flag:
            individual_coverage,

          current_carrier_excluded:
            carrier_excluded,

          current_carrier_excluded_explanation:
            exclusions,

          phone_number:
            carrier_phone,

          fax_number:
            carrier_fax,

          email_address:
            carrier_email,

          show_on_tickler:
            show_on_tickler,

          prof_liability_does_not_expire:
            does_not_expire,

          comment:
            source_comments,

          audit_status:
            liability_audit,

          claims_history_audit:
            claims_history_audit,

          form_type:
            "main"
        }

        # -----------------------------------------------------
        # Duplicate check
        # -----------------------------------------------------

        existing =
          ProviderInsuranceCoverage
            .where(
              provider_attest_id:
                ppi.provider_attest_id
            )
            .detect do |record|

            duplicate_match.call(
              record,
              attrs
            )
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing professional liability record found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Carrier=#{carrier_name}",
            "Policy=#{policy_number.inspect}",
            "Effective=#{original_start_date.inspect}",
            "Expiration=#{expiration_date.inspect}",
            "CoverageID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
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

            ProviderInsuranceCoverage.transaction do
              duplicate =
                ProviderInsuranceCoverage
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |record|

                  duplicate_match.call(
                    record,
                    attrs
                  )
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "Record appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  carrier_name,
                  "CoverageID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  carrier_name,
                  policy_holder,
                  policy_number,
                  original_start_date,
                  expiration_date,
                  occurrence_amount,
                  aggregate_amount,
                  does_not_expire,
                  verified_status,
                  verified_source,
                  source_tbl_xii_id,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_record =
                ProviderInsuranceCoverage.new(
                  attrs
                )

              # Legacy imports may contain values that do not satisfy
              # current interactive-form validations.
              created_record.save!(
                validate: false
              )
            end

            if created_record&.persisted?
              stats[:created] += 1

              message =
                "Created successfully"

              puts [
                "CREATED",
                encid,
                provider_name,
                "Carrier=#{carrier_name}",
                "Policy=#{policy_number.inspect}",
                "Effective=#{original_start_date.inspect}",
                "Expiration=#{expiration_date.inspect}",
                "DoesNotExpire=#{does_not_expire.inspect}",
                "Occurrence=#{occurrence_amount.inspect}",
                "Aggregate=#{aggregate_amount.inspect}",
                "CoverageID=#{created_record.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                carrier_name,
                policy_holder,
                policy_number,
                original_start_date,
                expiration_date,
                occurrence_amount,
                aggregate_amount,
                does_not_expire,
                verified_status,
                verified_source,
                source_tbl_xii_id,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_record.id,
                message
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
              carrier_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              carrier_name,
              policy_holder,
              policy_number,
              original_start_date,
              expiration_date,
              occurrence_amount,
              aggregate_amount,
              does_not_expire,
              verified_status,
              verified_source,
              source_tbl_xii_id,
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
            "Carrier=#{carrier_name}",
            "Policy=#{policy_number.inspect}",
            "Effective=#{original_start_date.inspect}",
            "Expiration=#{expiration_date.inspect}",
            "DoesNotExpire=#{does_not_expire.inspect}",
            "Occurrence=#{occurrence_amount.inspect}",
            "Aggregate=#{aggregate_amount.inspect}",
            "Audit=#{liability_audit.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            carrier_name,
            policy_holder,
            policy_number,
            original_start_date,
            expiration_date,
            occurrence_amount,
            aggregate_amount,
            does_not_expire,
            verified_status,
            verified_source,
            source_tbl_xii_id,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching professional liability record"
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
    puts "Target: ProviderInsuranceCoverage"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing liabilities skipped: #{stats[:existing]}"
    puts "Blank carriers skipped: #{stats[:blank_carrier]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end