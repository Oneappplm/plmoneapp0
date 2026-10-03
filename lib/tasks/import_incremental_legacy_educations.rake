require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy Education records into PracticeInformationEducation without modifying existing records"
  task import_incremental_legacy_educations: :environment do
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
        "practice_information_educations_#{timestamp}.csv"
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

      begin
        #
        # Legacy values can be:
        #
        #   9/2012
        #   10/2019
        #
        # When only month/year exists, use the first
        # day of that month.
        #
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
    puts "Incremental Legacy Education Import"
    puts "=" * 100
    puts "Target model: PracticeInformationEducation"
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
        "institution_name",
        "degree",
        "start_date",
        "end_date",
        "completed",
        "verification_status",
        "action",
        "ppi_id",
        "provider_attest_id",
        "practice_information_education_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        #
        # sqlcmd produces:
        #
        # -----|----------|...
        #
        next if row["ENCID"].to_s.strip.start_with?("-")

        client =
          row["ClientName"].to_s.strip

        encid =
          canonical_encid.call(
            row["ENCID"]
          )

        institution_name =
          clean_value.call(
            row["SchoolName"]
          )

        degree =
          clean_value.call(
            row["DegreeCertificate"]
          )

        start_date =
          parse_date.call(
            row["AttendedFrom"],
            row["DateAttendedFrom"]
          )

        end_date =
          parse_date.call(
            row["AttendedTo"],
            row["DateAttendedto"]
          )

        completed =
          parse_boolean.call(
            row["CompletedOrNot"]
          )

        incomplete_explanation =
          clean_value.call(
            row["Explanation"]
          )

        verification_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        comments =
          clean_value.call(
            row["Comments"]
          )

        #
        # Validate client.
        #
        unless allowed_clients.include?(client)
          stats[:unsupported_client] += 1

          message =
            "Unsupported client: #{client.inspect}"

          puts [
            "SKIP CLIENT",
            encid,
            institution_name,
            message
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "SKIPPED_CLIENT",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        #
        # Validate ENCID.
        #
        if encid.blank?
          stats[:invalid_encid] += 1

          message =
            "Missing or invalid ENCID"

          puts [
            "SKIP INVALID ENCID",
            institution_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        #
        # Education must have an institution.
        #
        if institution_name.blank?
          stats[:blank_institution] += 1

          message =
            "Missing institution name"

          puts [
            "SKIP BLANK INSTITUTION",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "SKIPPED_BLANK_INSTITUTION",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        #
        # Resolve the provider through ENCID.
        #
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
            institution_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
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

        #
        # Do not import a CUAN row into a PPC provider,
        # or vice versa.
        #
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
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            message
          ]

          next
        end

        #
        # Duplicate identity:
        #
        # provider_attest
        # + institution
        # + degree
        # + start date
        # + end date
        #
        existing =
          PracticeInformationEducation
            .where(
              provider_attest_id:
                ppi.provider_attest_id
            )
            .detect do |education|

            institution_matches =
              normalize_text.call(
                education.institution_name
              ) == normalize_text.call(
                institution_name
              )

            degree_matches =
              normalize_text.call(
                education.degree_degree_abbreviation
              ) == normalize_text.call(
                degree
              )

            start_matches =
              education.start_date&.to_date ==
                start_date

            end_matches =
              education.end_date&.to_date ==
                end_date

            institution_matches &&
              degree_matches &&
              start_matches &&
              end_matches
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing Education record found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Institution=#{institution_name}",
            "Degree=#{degree.inspect}",
            "EducationID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            message
          ]

          next
        end

        #
        # Correct Education-tab attributes.
        #
        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          institution_name:
            institution_name,

          degree_degree_abbreviation:
            degree,

          start_date:
            start_date,

          end_date:
            end_date,

          program_completed_flag:
            completed,

          incomplete_explanation:
            incomplete_explanation,

          verification_status:
            verification_status,

          comments:
            comments,

          #
          # Existing legacy Education rows commonly use
          # nil. The UI explicitly accepts nil and "main".
          #
          form_type:
            nil,

          show_on_tickler:
            false
        }

        if apply
          begin
            created_education = nil

            PracticeInformationEducation.transaction do
              #
              # Re-check while transaction is active.
              #
              duplicate =
                PracticeInformationEducation
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |education|

                  institution_matches =
                    normalize_text.call(
                      education.institution_name
                    ) == normalize_text.call(
                      institution_name
                    )

                  degree_matches =
                    normalize_text.call(
                      education.degree_degree_abbreviation
                    ) == normalize_text.call(
                      degree
                    )

                  start_matches =
                    education.start_date&.to_date ==
                      start_date

                  end_matches =
                    education.end_date&.to_date ==
                      end_date

                  institution_matches &&
                    degree_matches &&
                    start_matches &&
                    end_matches
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "Education appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  institution_name,
                  "EducationID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  institution_name,
                  degree,
                  start_date,
                  end_date,
                  completed,
                  verification_status,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_education =
                PracticeInformationEducation.new(
                  attrs
                )

              created_education.save!(
                validate: false
              )
            end

            if created_education&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "Institution=#{institution_name}",
                "Degree=#{degree.inspect}",
                "EducationID=#{created_education.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                institution_name,
                degree,
                start_date,
                end_date,
                completed,
                verification_status,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_education.id,
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
              institution_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              institution_name,
              degree,
              start_date,
              end_date,
              completed,
              verification_status,
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
            "Institution=#{institution_name}",
            "Degree=#{degree.inspect}",
            "Start=#{start_date.inspect}",
            "End=#{end_date.inspect}",
            "Completed=#{completed.inspect}",
            "Verification=#{verification_status.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            degree,
            start_date,
            end_date,
            completed,
            verification_status,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching Education record"
          ]
        end
      end
    end

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Target: PracticeInformationEducation"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing educations skipped: #{stats[:existing]}"
    puts "Blank institutions skipped: #{stats[:blank_institution]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end
