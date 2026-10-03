require "csv"
require "fileutils"
require "date"

namespace :legacy do
  desc "Incrementally import legacy training records without modifying existing records"
  task import_incremental_legacy_trainings: :environment do
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
        "trainings_#{timestamp}.csv"
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

    duplicate_match = lambda do |training, attrs|
      institution_matches =
        normalize_text.call(training.institution_name) ==
          normalize_text.call(attrs[:institution_name])

      program_type_matches =
        normalize_text.call(training.program_type) ==
          normalize_text.call(attrs[:program_type])

      specialty_matches =
        normalize_text.call(training.specialty_specialty_name) ==
          normalize_text.call(attrs[:specialty_specialty_name])

      start_matches =
        training.start_date&.to_date ==
          attrs[:start_date]

      end_matches =
        training.end_date&.to_date ==
          attrs[:end_date]

      institution_matches &&
        program_type_matches &&
        specialty_matches &&
        start_matches &&
        end_matches
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy Training Import"
    puts "=" * 100
    puts "Target model: ProviderEducation"
    puts "education_type_name: Training"
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
        "institution_name",
        "training_type",
        "specialty",
        "start_date",
        "end_date",
        "completed",
        "audit_status",
        "verification_comments",
        "source_training_guid",
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

        # Skip sqlcmd separator row:
        # -----|------|...
        next if row["ENCID"].to_s.strip.start_with?("-")

        client =
          row["ClientName"].to_s.strip

        encid =
          canonical_encid.call(
            row["ENCID"]
          )

        institution_name =
          clean_value.call(
            row["InstitutionName"]
          )

        training_type =
          clean_value.call(
            row["TrainingType"]
          )

        specialty =
          clean_value.call(
            row["SpecialtyName"]
          )

        director_first_name =
          clean_value.call(
            row["ProgramDirectorFirstName"]
          )

        director_last_name =
          clean_value.call(
            row["ProgramDirectorLastName"]
          )

        program_director =
          [
            director_first_name,
            director_last_name
          ].compact.join(" ").presence

        start_date =
          parse_date.call(
            row["DateAttendedFrom"]
          )

        end_date =
          parse_date.call(
            row["DateAttendedTo"]
          )

        completed =
          parse_boolean.call(
            row["CompletedOrNot"]
          )

        apa_approved =
          parse_boolean.call(
            row["APAApproved"]
          )

        explanation =
          clean_value.call(
            row["Explanation"]
          )

        comments =
          clean_value.call(
            row["Comments"]
          )

        verified_status =
          clean_value.call(
            row["VerifiedStatus"]
          )

        verification_comments =
          clean_value.call(
            row["VerificationComments"]
          )

        show_on_tickler =
          parse_boolean.call(
            row["ShowOnTickler"]
          )

        source_training_guid =
          clean_value.call(
            row["SourceTrainingGUID"]
          )

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
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
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
            institution_name
          ].join(" | ")

          report << [
            client,
            nil,
            nil,
            institution_name,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            message
          ]

          next
        end

        if institution_name.blank?
          stats[:blank_institution] += 1

          message =
            "Missing InstitutionName"

          puts [
            "SKIP BLANK INSTITUTION",
            encid
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            nil,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
            "SKIPPED_BLANK_INSTITUTION",
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
            institution_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            institution_name,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
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
            institution_name,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
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

          institution_name:
            institution_name,

          education_type_name:
            "Training",

          form_type:
            "main",

          program_title:
            training_type,

          program_type:
            training_type,

          training_area:
            specialty,

          specialty_specialty_name:
            specialty,

          start_date:
            start_date,

          end_date:
            end_date,

          program_completed_flag:
            completed,

          incomplete_explanation:
            explanation,

          apa_approved_flag:
            apa_approved,

          program_director:
            program_director,

          comments:
            comments,

          audit_status:
            verified_status,

          show_on_tickler:
            show_on_tickler
        }

        existing =
          ProviderEducation
            .where(
              provider_attest_id:
                ppi.provider_attest_id,
              education_type_name:
                "Training"
            )
            .detect do |training|

            duplicate_match.call(
              training,
              attrs
            )
          end

        if existing
          stats[:existing] += 1

          message =
            "Existing training found; left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "Institution=#{institution_name}",
            "Type=#{training_type.inspect}",
            "Specialty=#{specialty.inspect}",
            "Start=#{start_date.inspect}",
            "End=#{end_date.inspect}",
            "TrainingID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
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
            created_training = nil

            ProviderEducation.transaction do
              duplicate =
                ProviderEducation
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id,
                    education_type_name:
                      "Training"
                  )
                  .detect do |training|

                  duplicate_match.call(
                    training,
                    attrs
                  )
                end

              if duplicate
                stats[:existing] += 1

                message =
                  "Training appeared before create; left unchanged"

                puts [
                  "SKIP EXISTING",
                  encid,
                  institution_name,
                  "TrainingID=#{duplicate.id}"
                ].join(" | ")

                report << [
                  client,
                  encid,
                  provider_name,
                  institution_name,
                  training_type,
                  specialty,
                  start_date,
                  end_date,
                  completed,
                  verified_status,
                  verification_comments,
                  source_training_guid,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  message
                ]

                next
              end

              created_training =
                ProviderEducation.new(
                  attrs
                )

              created_training.save!(
                validate: false
              )
            end

            if created_training&.persisted?
              stats[:created] += 1

              message =
                if verification_comments.to_s.casecmp("SkipRVA").zero?
                  "Created successfully; source verification comment is SkipRVA"
                else
                  "Created successfully"
                end

              puts [
                "CREATED",
                encid,
                provider_name,
                "Institution=#{institution_name}",
                "Type=#{training_type.inspect}",
                "Specialty=#{specialty.inspect}",
                "Start=#{start_date.inspect}",
                "End=#{end_date.inspect}",
                "Status=#{verified_status.inspect}",
                "TrainingID=#{created_training.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                institution_name,
                training_type,
                specialty,
                start_date,
                end_date,
                completed,
                verified_status,
                verification_comments,
                source_training_guid,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_training.id,
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
              institution_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              institution_name,
              training_type,
              specialty,
              start_date,
              end_date,
              completed,
              verified_status,
              verification_comments,
              source_training_guid,
              "ERROR",
              ppi.id,
              ppi.provider_attest_id,
              nil,
              message
            ]
          end

        else
          stats[:would_create] += 1

          warning =
            if verification_comments.to_s.casecmp("SkipRVA").zero?
              " | VerificationComment=SkipRVA"
            else
              ""
            end

          puts [
            "WOULD_CREATE",
            encid,
            provider_name,
            "Institution=#{institution_name}",
            "Type=#{training_type.inspect}",
            "Specialty=#{specialty.inspect}",
            "Start=#{start_date.inspect}",
            "End=#{end_date.inspect}",
            "Completed=#{completed.inspect}",
            "Status=#{verified_status.inspect}"
          ].join(" | ") + warning

          report << [
            client,
            encid,
            provider_name,
            institution_name,
            training_type,
            specialty,
            start_date,
            end_date,
            completed,
            verified_status,
            verification_comments,
            source_training_guid,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            verification_comments.to_s.casecmp("SkipRVA").zero? ?
              "No existing training; source verification comment is SkipRVA" :
              "No existing matching training"
          ]
        end
      end
    end

    puts
    puts "=" * 100
    puts "Import Summary"
    puts "=" * 100
    puts "Target: ProviderEducation"
    puts "Education type: Training"
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"

    if apply
      puts "Created: #{stats[:created]}"
    else
      puts "Would create: #{stats[:would_create]}"
    end

    puts "Existing trainings skipped: #{stats[:existing]}"
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