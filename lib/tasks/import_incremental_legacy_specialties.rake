require "csv"
require "fileutils"

namespace :legacy do
  desc "Incrementally import legacy provider specialties without modifying existing specialty records"
  task import_incremental_legacy_specialties: :environment do
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
    report_file = report_dir.join("specialties_#{timestamp}.csv")

    stats = Hash.new(0)

    normalize_encid = lambda do |value|
      value = value.to_s.strip.upcase
      digits = value.gsub(/\D/, "")
      next nil if digits.blank?

      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    normalize_text = lambda do |value|
      value.to_s.strip.downcase.gsub(/\s+/, " ")
    end

    clean_value = lambda do |value|
      value = value.to_s.strip
      next nil if value.blank? || value.casecmp("NULL").zero?

      value
    end

    parse_boolean = lambda do |value|
      case value.to_s.strip.downcase
      when "yes", "y", "true", "1", "t", "certified"
        true
      when "no", "n", "false", "0", "f"
        false
      else
        nil
      end
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy Specialty Import"
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
        "specialty_name",
        "taxonomy_code",
        "ranking_order",
        "board_cert_status",
        "action",
        "ppi_id",
        "provider_attest_id",
        "provider_specialty_id",
        "message"
      ]

      CSV.foreach(
        file,
        headers: true,
        col_sep: "|",
        skip_blanks: true
      ) do |row|

        next if row["ENCID"].to_s.strip.start_with?("-")

        client = row["ClientName"].to_s.strip
        encid = normalize_encid.call(row["ENCID"])

        specialty_name =
          clean_value.call(row["SpecialtyName"])

        taxonomy_code =
          clean_value.call(row["TaxonomyCode"])

        ranking_order =
          clean_value.call(row["RankingOrder"])

        board_cert_status =
          clean_value.call(row["BoardCertStatus"])

        if client.blank? || !allowed_clients.include?(client)
          stats[:unsupported_client] += 1

          report << [
            client,
            encid,
            nil,
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
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
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
            "SKIPPED_INVALID_ENCID",
            nil,
            nil,
            nil,
            "Missing or invalid ENCID"
          ]

          next
        end

        if specialty_name.blank?
          stats[:blank_specialty] += 1

          report << [
            client,
            encid,
            nil,
            nil,
            taxonomy_code,
            ranking_order,
            board_cert_status,
            "SKIPPED_BLANK_SPECIALTY",
            nil,
            nil,
            nil,
            "Blank specialty name"
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
            specialty_name
          ].join(" | ")

          report << [
            client,
            encid,
            nil,
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
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
            provider_name
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
            "SKIPPED_CLIENT_MISMATCH",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "Provider belongs to #{ppi.legacy_client_name.inspect}"
          ]

          next
        end

        existing =
          ProviderSpecialty
            .where(provider_attest_id: ppi.provider_attest_id)
            .detect do |specialty|

            name_matches =
              normalize_text.call(
                specialty.specialty_specialty_name
              ) == normalize_text.call(specialty_name)

            taxonomy_matches =
              normalize_text.call(
                specialty.sub_specialty_specialty_name
              ) == normalize_text.call(taxonomy_code)

            name_matches && taxonomy_matches
          end

        if existing
          stats[:existing] += 1

          puts [
            "SKIP EXISTING",
            encid,
            "Specialty=#{specialty_name}",
            "Taxonomy=#{taxonomy_code.inspect}",
            "SpecialtyID=#{existing.id}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
            "SKIPPED_EXISTING",
            ppi.id,
            ppi.provider_attest_id,
            existing.id,
            "Existing specialty found; left unchanged"
          ]

          next
        end

        board_flag =
          parse_boolean.call(board_cert_status)

        attrs = {
          provider_attest_id:
            ppi.provider_attest_id,

          caqh_provider_attest_id:
            ppi.caqh_provider_attest_id,

          specialty_specialty_name:
            specialty_name,

          sub_specialty_specialty_name:
            taxonomy_code,

          specialty_percent:
            ranking_order,

          board_certified:
            board_flag,

          board_certified_flag:
            board_flag
        }

        if apply
          begin
            created_specialty = nil

            ProviderSpecialty.transaction do
              duplicate =
                ProviderSpecialty
                  .lock
                  .where(
                    provider_attest_id:
                      ppi.provider_attest_id
                  )
                  .detect do |specialty|

                  name_matches =
                    normalize_text.call(
                      specialty.specialty_specialty_name
                    ) == normalize_text.call(specialty_name)

                  taxonomy_matches =
                    normalize_text.call(
                      specialty.sub_specialty_specialty_name
                    ) == normalize_text.call(taxonomy_code)

                  name_matches && taxonomy_matches
                end

              if duplicate
                stats[:existing] += 1

                report << [
                  client,
                  encid,
                  provider_name,
                  specialty_name,
                  taxonomy_code,
                  ranking_order,
                  board_cert_status,
                  "SKIPPED_EXISTING",
                  ppi.id,
                  ppi.provider_attest_id,
                  duplicate.id,
                  "Specialty appeared before create; left unchanged"
                ]

                next
              end

              created_specialty =
                ProviderSpecialty.new(attrs)

              created_specialty.save!(
                validate: false
              )
            end

            if created_specialty&.persisted?
              stats[:created] += 1

              puts [
                "CREATED",
                encid,
                provider_name,
                "Specialty=#{specialty_name}",
                "Taxonomy=#{taxonomy_code.inspect}",
                "SpecialtyID=#{created_specialty.id}"
              ].join(" | ")

              report << [
                client,
                encid,
                provider_name,
                specialty_name,
                taxonomy_code,
                ranking_order,
                board_cert_status,
                "CREATED",
                ppi.id,
                ppi.provider_attest_id,
                created_specialty.id,
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
              specialty_name,
              message
            ].join(" | ")

            report << [
              client,
              encid,
              provider_name,
              specialty_name,
              taxonomy_code,
              ranking_order,
              board_cert_status,
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
            "Specialty=#{specialty_name}",
            "Taxonomy=#{taxonomy_code.inspect}",
            "Rank=#{ranking_order.inspect}",
            "BoardCertified=#{board_flag.inspect}"
          ].join(" | ")

          report << [
            client,
            encid,
            provider_name,
            specialty_name,
            taxonomy_code,
            ranking_order,
            board_cert_status,
            "WOULD_CREATE",
            ppi.id,
            ppi.provider_attest_id,
            nil,
            "No existing matching specialty"
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

    puts "Existing specialties skipped: #{stats[:existing]}"
    puts "Blank specialties skipped: #{stats[:blank_specialty]}"
    puts "Missing providers: #{stats[:missing_provider]}"
    puts "Client mismatches: #{stats[:client_mismatch]}"
    puts "Unsupported clients: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end