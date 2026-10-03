require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy provider education records without modifying existing records"
  task import_incremental_legacy_educations: :environment do
    file = ENV.fetch("FILE")
    apply = ENV["APPLY"].to_s.downcase == "true"

    abort "File not found: #{file}" unless File.exist?(file)

    allowed_clients =
      ENV.fetch(
        "CLIENTS",
        "CUAN,Primary PartnersCare,Broward Health"
      ).split(",").map(&:strip)

    report_dir = Rails.root.join("tmp", "legacy_import_reports")
    FileUtils.mkdir_p(report_dir)

    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    report_file = report_dir.join("educations_#{timestamp}.csv")

    stats = Hash.new(0)

    normalize_encid = lambda do |value|
      value = value.to_s.strip.upcase
      digits = value.gsub(/\D/, "")

      next nil if digits.blank?

      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    clean_value = lambda do |value|
      value = value.to_s.strip

      next nil if value.blank? ||
                  value.casecmp("NULL").zero?

      value
    end

    normalize_text = lambda do |value|
      value.to_s.strip.downcase.gsub(/\s+/, " ")
    end

    parse_date = lambda do |primary_value, fallback_value = nil|
      primary = clean_value.call(primary_value)

      if primary.present?
        begin
          next Date.parse(primary)
        rescue ArgumentError, TypeError
          # Try fallback below.
        end
      end

      fallback = clean_value.call(fallback_value)
      next nil if fallback.blank?

      begin
        # Handles values such as 9/2012, 10/2019.
        if fallback.match?(/\A\d{1,2}\/\d{4}\z/)
          month, year = fallback.split("/").map(&:to_i)
          next Date.new(year, month, 1)
        end

        Date.parse(fallback)
      rescue ArgumentError, TypeError
        nil
      end
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

    puts
    puts "=" * 100
    puts "Incremental Legacy Education Import"
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
        "institution_name",
        "degree",
        "start_date",
        "end_date",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_education_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        # Skip sqlcmd separator line.
        next if row["ENCID"].to_s.strip.start_with?("-")

        client = row["ClientName"].to_s.strip
        encid = normalize_encid.call(row["ENCID"])

        institution_name =
          clean_value.call(row["SchoolName"])

        degree =
          clean_value.call(row["DegreeCertificate"])

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
          parse_boolean.call(row["CompletedOrNot"])

        explanation =
          clean_value.call(row["Explanation"])

        audit_status =
          clean_value.call(row["VerifiedStatus"])

        comments =
          clean_value.call(row["Comments"])

        unless allowed_clients.include?(client)
          stats[:unsupported_client] += 1

          puts [
            "SKIP CLIENT",
            encid,
            institution_name,
            client.inspect
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            institution_name,
            degree,
            start_date,
            end_date,
            "SKIPPED_CLIENT",
            nil,
            nil,
            nil,
            "Unsupported client"
          ]

          next
        end

        if encid.blank?
          stats[:invalid_encid] += 1

          report << [
            client,
            nil,
            nil,
            institution_name,
            degree,
            start_date,
            end_date,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            "Missing or invalid ENCID"
          ]

          next
        end

        if institution_name.blank?
          stats[:blank_institution] += 1

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
            "SKIPPED_BLANK_INSTITUTION",
            nil,
            nil,
            nil,
            "Missing institution name"
          ]

          next
        end

        ppi =
          ProviderPersonalInformation.find_by(
            encompass_id_text: encid
          )

        unless ppi
          stats[:missing_provider] += 1

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
            "SKIPPED_MISSING_PROVIDER",
            nil,
            nil,
            nil,
            "Provider not found"
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

          puts [
            "SKIP CLIENT MISMATCH",
            encid,
            provider_name,
            client.inspect,
            ppi.legacy_client_name.inspect
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            degree,
            start_date,
            end_date,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "Provider belongs to #{ppi.legacy_client_name.inspect}"
          ]

          next
        end

        existing =
          ProviderEducation
            .where(
              provider_attest_id: ppi.provider_attest_id
            )
            .detect do |education|

            institution_matches =
              normalize_text.call(
                education.institution_name
              ) == normalize_text.call(institution_name)

            degree_matches =
              normalize_text.call(
                education.degree_degree_abbreviation
              ) == normalize_text.call(degree)

            start_matches =
              education.start_date&.to_date == start_date

            end_matches =
              education.end_date&.to_date == end_date

            institution_matches &&
              degree_matches &&
              start_matches &&
              end_matches
          end

        if existing
          stats[:existing] += 1

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
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            "Existing education found; left unchanged"
          ]

          next
        end

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
            explanation,

          audit_status:
            audit_status,

          comments:
            comments,

          education_type_name:
            "Education"
        }

        if apply
          begin
            created_education = nil

            ProviderEducation.transaction do
              duplicate =
                ProviderEducation
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |education|

                  institution_matches =
                    normalize_text.call(
                      education.institution_name
                    ) == normalize_text.call(institution_name)

                  degree_matches =
                    normalize_text.call(
                      education.degree_degree_abbreviation
                    ) == normalize_text.call(degree)

                  start_matches =
                    education.start_date&.to_date == start_date

                  end_matches =
                    education.end_date&.to_date == end_date

                  institution_matches &&
                    degree_matches &&
                    start_matches &&
                    end_matches
                end

              if duplicate
                stats[:existing] += 1

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
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  "Education appeared before create; left unchanged"
                ]

                next
              end

              created_education =
                ProviderEducation.new(attrs)

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
            "Status=#{audit_status.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            degree,
            start_date,
            end_date,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching education"
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
