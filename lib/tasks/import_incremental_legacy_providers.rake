require "csv"
require "fileutils"

namespace :legacy do
  desc "Incrementally import legacy providers without modifying existing provider records"
  task import_incremental_legacy_providers: :environment do
    file = ENV.fetch("FILE")
    apply = ENV["APPLY"].to_s.downcase == "true"

    unless File.exist?(file)
      abort "File not found: #{file}"
    end

    allowed_clients = ENV.fetch("CLIENTS", "CUAN,Primary PartnersCare,Broward Health").split(",").map(&:strip)

    report_dir = Rails.root.join("tmp", "legacy_import_reports")
    FileUtils.mkdir_p(report_dir)

    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    report_file = report_dir.join("providers_#{timestamp}.csv")
    stats = Hash.new(0)

    canonical_encid = lambda do |value|
      value = value.to_s.strip.upcase
      digits = value.gsub(/\D/, "")
      next nil if digits.blank?
      "ENC#{digits.to_i.to_s.rjust(6, "0")}"
    end

    normalize_name = lambda do |value|
      value.to_s.strip.downcase.gsub(/\s+/, " ")
    end

    puts
    puts "=" * 100
    puts "Incremental Legacy Provider Import"
    puts "=" * 100
    puts "Mode: #{apply ? 'APPLY' : 'DRY RUN'}"
    puts "File: #{file}"
    puts "Allowed clients: #{allowed_clients.join(', ')}"
    puts "Report: #{report_file}"
    puts "=" * 100
    puts

    CSV.open(report_file, "w") do |report|
      report << ["client", "encid", "source_prac_id", "name", "action", "ppi_id", "provider_attest_id", "message"]

      CSV.foreach(file, headers: true, col_sep: "|", skip_blanks: true) do |row|
        # Skip sqlcmd separator line:
        # --------|------|...
        next if row["ClientName"].to_s.strip.start_with?("-")

        client = row["ClientName"].to_s.strip
        raw_encid = row["ENCID"].presence || row["SourcePracID"].presence
        encid = canonical_encid.call(raw_encid)

        first_name = row["FirstName"].to_s.strip.presence
        middle_name = row["MiddleName"].to_s.strip.presence
        last_name = row["LastName"].to_s.strip.presence
        full_name = [first_name, middle_name, last_name].compact.join(" ")

        birth_date = begin
          Date.parse(row["BirthDate"].to_s)
        rescue ArgumentError, TypeError
          nil
        end

        unless allowed_clients.include?(client)
          stats[:unsupported_client] += 1
          message = "Unsupported client: #{client.inspect}"
          puts "SKIP CLIENT | #{encid || raw_encid} | #{message}"

          report << [client, encid, row["SourcePracID"], full_name, "SKIPPED_CLIENT", nil, nil, message]
          next
        end

        if encid.blank?
          stats[:invalid_encid] += 1
          message = "Missing or invalid ENCID"
          puts "SKIP INVALID | #{full_name} | #{message}"

          report << [client, nil, row["SourcePracID"], full_name, "SKIPPED_INVALID", nil, nil, message]
          next
        end

        existing = ProviderPersonalInformation.find_by(encompass_id_text: encid)

        if existing
          stats[:existing] += 1
          message = "Existing ENCID; record left unchanged"

          puts [
            "SKIP EXISTING",
            encid,
            "PPI=#{existing.id}",
            "#{existing.first_name} #{existing.last_name}",
            existing.legacy_client_name.inspect
          ].join(" | ")

          report << [client, encid, row["SourcePracID"], full_name, "SKIPPED_EXISTING", existing.id, existing.provider_attest_id, message]
          next
        end

        duplicate_scope = ProviderPersonalInformation.where("LOWER(first_name) = ? AND LOWER(last_name) = ?", normalize_name.call(first_name), normalize_name.call(last_name))

        if birth_date
          duplicate_scope = duplicate_scope.where("DATE(birth_date) = ?", birth_date)
        end

        duplicate_matches = duplicate_scope.limit(20).to_a

        if duplicate_matches.any?
          stats[:identity_warning] += 1

          warning = duplicate_matches.map do |ppi|
            ["PPI=#{ppi.id}", "ENCID=#{ppi.encompass_id_text.inspect}", "CLIENT=#{ppi.legacy_client_name.inspect}"].join(" ")
          end.join("; ")

          puts
          puts ["IDENTITY WARNING", encid, full_name, birth_date, warning].join(" | ")
        end

        attrs = {
          encompass_id_text: encid,
          caqh_provider_attest_id: encid.gsub(/\D/, "").to_i,
          first_name: first_name,
          middle_name: middle_name,
          last_name: last_name,
          suffix: row["Suffix"].to_s.strip.presence,
          birth_date: birth_date,
          ssn: row["SSN"].to_s.strip.presence,
          practitioner_type: row["PractitionerType"].to_s.strip.presence,
          legacy_client_name: client
        }

        if apply
          begin
            ppi = nil
            attest = nil

            ProviderPersonalInformation.transaction do
              # Recheck inside transaction so repeated/racing runs
              # cannot silently overwrite an existing ENCID.
              existing_inside_transaction = ProviderPersonalInformation.lock.find_by(encompass_id_text: encid)

              if existing_inside_transaction
                stats[:existing] += 1
                message = "ENCID appeared before create; left unchanged"

                puts ["SKIP EXISTING", encid, "PPI=#{existing_inside_transaction.id}"].join(" | ")

                report << [client, encid, row["SourcePracID"], full_name, "SKIPPED_EXISTING", existing_inside_transaction.id, existing_inside_transaction.provider_attest_id, message]
                next
              end

              attest = ProviderAttest.create!
              ppi = ProviderPersonalInformation.new(attrs)
              ppi.provider_attest_id = attest.id
              ppi.save!(validate: false)
            end

            if ppi&.persisted?
              stats[:created] += 1
              message = duplicate_matches.any? ? "Created with identity warning" : "Created successfully"

              puts ["CREATED", encid, "PPI=#{ppi.id}", "ProviderAttest=#{attest.id}", client, full_name].join(" | ")
              report << [client, encid, row["SourcePracID"], full_name, "CREATED", ppi.id, attest.id, message]
            end
          rescue => e
            stats[:errors] += 1
            message = "#{e.class}: #{e.message}"

            puts ["ERROR", encid, full_name, message].join(" | ")
            report << [client, encid, row["SourcePracID"], full_name, "ERROR", nil, nil, message]
          end
        else
          stats[:would_create] += 1
          action = duplicate_matches.any? ? "WOULD_CREATE_WITH_WARNING" : "WOULD_CREATE"

          puts [
            action,
            encid,
            full_name,
            "DOB=#{birth_date}",
            "TYPE=#{attrs[:practitioner_type]}",
            "CLIENT=#{client}"
          ].join(" | ")

          report << [
            client,
            encid,
            row["SourcePracID"],
            full_name,
            action,
            nil,
            nil,
            duplicate_matches.any? ? "Identity match exists; existing records will not be modified" : "No existing ENCID or identity match"
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

    puts "Existing ENCID skipped: #{stats[:existing]}"
    puts "Identity warnings: #{stats[:identity_warning]}"
    puts "Unsupported client: #{stats[:unsupported_client]}"
    puts "Invalid ENCID: #{stats[:invalid_encid]}"
    puts "Errors: #{stats[:errors]}"
    puts "Report: #{report_file}"
    puts "=" * 100
  end
end