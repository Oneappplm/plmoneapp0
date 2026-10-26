require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy peer references without modifying existing records"
  task import_incremental_legacy_peer_references: :environment do
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
        "peer_references_#{timestamp}.csv"
      )

    stats = Hash.new(0)

    model = ProviderPersonalInformationPeerRef
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

    normalize_text = lambda do |value|
      clean_value.call(value)
        .to_s
        .downcase
        .gsub(/\s+/, " ")
        .strip
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

    parse_datetime = lambda do |value|
      value = clean_value.call(value)

      next nil if value.blank?

      begin
        Time.zone.parse(value)
      rescue ArgumentError, TypeError
        nil
      end
    end

    build_comments = lambda do |source_comments, verification_comments|
      parts = []

      if source_comments.present?
        parts << source_comments
      end

      if verification_comments.present? &&
         normalize_text.call(verification_comments) !=
           normalize_text.call(source_comments)

        parts << verification_comments
      end

      parts.presence&.join(" | ")
    end

    # Only assign attributes that actually exist in production model.
    filter_attributes = lambda do |attrs|
      attrs.select do |key, _value|
        model_columns.include?(key.to_s)
      end
    end

    duplicate_match = lambda do |record, attrs|
      first_match =
        normalize_text.call(record.first_name) ==
          normalize_text.call(attrs[:first_name])

      middle_match =
        normalize_text.call(record.middle_name) ==
          normalize_text.call(attrs[:middle_name])

      last_match =
        normalize_text.call(record.last_name) ==
          normalize_text.call(attrs[:last_name])

      email_match =
        normalize_text.call(record.email_address) ==
          normalize_text.call(attrs[:email_address])

      phone_match =
        normalize_text.call(record.phone_number) ==
          normalize_text.call(attrs[:phone_number])

      #
      # Name is required for duplicate matching.
      #
      # Email / phone provide additional protection when present.
      #
      first_match &&
        middle_match &&
        last_match &&
        email_match &&
        phone_match
    end

    # ---------------------------------------------------------
    # Header
    # ---------------------------------------------------------

    puts
    puts "=" * 100
    puts "Incremental Legacy Peer Reference Import"
    puts "=" * 100
    puts "Target model: ProviderPersonalInformationPeerRef"
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
        "peer_name",
        "title",
        "practitioner_type",
        "specialty",
        "board_certified",
        "email",
        "phone",
        "city",
        "state",
        "quality_audit_complete",
        "verified_status",
        "verified_source",
        "source_peer_reference_guid",
        "action",
        "ppi_id",
        "provider_attest_id",
        "peer_reference_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        # sqlcmd separator row
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

        first_name =
          clean_value.call(
            row["FirstName"]
          )

        middle_name =
          clean_value.call(
            row["MiddleName"]
          )

        last_name =
          clean_value.call(
            row["LastName"]
          )

        suffix =
          clean_value.call(
            row["Suffix"]
          )

        title =
          clean_value.call(
            row["Title"]
          )

        practitioner_type =
          clean_value.call(
            row["PractitionerType"]
          )

        specialty =
          clean_value.call(
            row["Specialty"]
          )

        board_certified =
          parse_boolean.call(
            row["BoardCertified"]
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

        county =
          clean_value.call(
            row["County"]
          )

        country =
          clean_value.call(
            row["Country"]
          )

        zip =
          clean_value.call(
            row["Zip"]
          )

        phone =
          clean_value.call(
            row["Phone"]
          )

        fax =
          clean_value.call(
            row["Fax"]
          )

        email =
          clean_value.call(
            row["Email"]
          )

        facility =
          clean_value.call(
            row["FacilityName"]
          )

        contact_method =
          clean_value.call(
            row["ContactMethod"]
          )

        source_comments =
          clean_value.call(
            row["SourceComments"]
          )

        show_on_tickler =
          parse_boolean.call(
            row["ShowOnTickler"]
          )

        quality_audit =
          boolean_string.call(
            row["QualityAuditComplete"]
          )

        verification_complete_date =
          parse_datetime.call(
            row["VerificationCompleteDate"]
          )

        verified_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        verified_date =
          parse_datetime.call(
            row["VerifiedDate"]
          )

        verified_source =
          clean_value.call(
            row["VerifiedSource"]
          )

        verified_good_standing =
          clean_value.call(
            row["VerifiedInGoodStanding"]
          )

        verification_comments =
          clean_value.call(
            row["VerificationComments"]
          )

        source_guid =
          clean_value.call(
            row["SourcePeerReferenceGUID"]
          )

        source_created_at =
          parse_datetime.call(
            row["SourceCreatedAt"]
          )

        peer_name =
          [
            first_name,
            middle_name,
            last_name
          ].compact.join(" ")

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
            peer_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
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
            peer_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
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
        # Peer name required
        # -----------------------------------------------------

        if first_name.blank? || last_name.blank?
          stats[:blank_peer_name] += 1

          message =
            "Peer first name or last name missing"

          puts [
            "SKIP BLANK PEER",
            encid,
            peer_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
            verified_source,
            source_guid,
            "SKIPPED_BLANK_PEER",
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
            peer_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
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
            peer_name
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
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
        # Build comments
        # -----------------------------------------------------

        comments =
          build_comments.call(
            source_comments,
            verification_comments
          )

        # -----------------------------------------------------
        # Build Rails attributes
        # -----------------------------------------------------

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          title:
            title,

          first_name:
            first_name,

          middle_name:
            middle_name,

          last_name:
            last_name,

          suffix:
            suffix,

          practitioner_type:
            practitioner_type,

          specialty:
            specialty,

          is_board_certified:
            board_certified,

          contact_method:
            contact_method,

          address:
            address,

          suite_dept_mail_stop:
            suite,

          facility_name:
            facility,

          city:
            city,

          country:
            country,

          state:
            state,

          county:
            county,

          zip_code:
            zip,

          phone_number:
            phone,

          fax_number:
            fax,

          email_address:
            email,

          comments:
            comments,

          show_on_tickler:
            show_on_tickler,

          audit_status:
            quality_audit
        }

        attrs =
          filter_attributes.call(attrs)

        # -----------------------------------------------------
        # Duplicate protection
        # -----------------------------------------------------

        existing =
          model
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
            "Existing peer reference found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Peer=#{peer_name}",
            "Email=#{email.inspect}",
            "Phone=#{phone.inspect}",
            "PeerReferenceID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
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

                  duplicate_match.call(
                    record,
                    attrs
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
                "Peer=#{peer_name}",
                "PeerReferenceID=#{duplicate_during_apply.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                peer_name,
                title,
                practitioner_type,
                specialty,
                board_certified,
                email,
                phone,
                city,
                state,
                quality_audit,
                verified_status,
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

              message =
                "Created successfully"

              puts [
                "CREATED",
                encid,
                provider_name,
                "Peer=#{peer_name}",
                "Title=#{title.inspect}",
                "Type=#{practitioner_type.inspect}",
                "Specialty=#{specialty.inspect}",
                "Email=#{email.inspect}",
                "Phone=#{phone.inspect}",
                "Audit=#{quality_audit.inspect}",
                "PeerReferenceID=#{created_record.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                peer_name,
                title,
                practitioner_type,
                specialty,
                board_certified,
                email,
                phone,
                city,
                state,
                quality_audit,
                verified_status,
                verified_source,
                source_guid,
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
              "Peer=#{peer_name}",
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              peer_name,
              title,
              practitioner_type,
              specialty,
              board_certified,
              email,
              phone,
              city,
              state,
              quality_audit,
              verified_status,
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
            "Peer=#{peer_name}",
            "Title=#{title.inspect}",
            "Type=#{practitioner_type.inspect}",
            "Specialty=#{specialty.inspect}",
            "BoardCertified=#{board_certified.inspect}",
            "Email=#{email.inspect}",
            "Phone=#{phone.inspect}",
            "State=#{state.inspect}",
            "Audit=#{quality_audit.inspect}",
            "Verified=#{verified_status.inspect}",
            "Source=#{verified_source.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            peer_name,
            title,
            practitioner_type,
            specialty,
            board_certified,
            email,
            phone,
            city,
            state,
            quality_audit,
            verified_status,
            verified_source,
            source_guid,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching peer reference"
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
    puts "Target: ProviderPersonalInformationPeerRef"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing peer references skipped: #{stats[:existing]}"
    puts "Blank peer names skipped: #{stats[:blank_peer_name]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end