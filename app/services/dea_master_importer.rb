class DeaMasterImporter
  FIELD_MAP = {
    dea_number:            0..10,
    schedules:             11..27,
    expiration_raw:        28..35,
    business_activity:     36..71,
    name:                  72..107,
    address1:              108..143,
    address2:              144..179,
    city:                  180..215,
    state:                 216..217,
    zip:                   218..226,
    status:                227..236,
    state_license_number:  237..270
  }.freeze

  BATCH_SIZE     = 2000
  PROGRESS_EVERY = 5000

  def initialize(file_path, job_id)
    @file_path = file_path
    @job_id    = job_id
  end

  def import!
    redis = $redis
    key   = "dea_import:#{@job_id}"

    processed = 0
    buffer = []

    File.foreach(@file_path, encoding: "bom|utf-8") do |line|
      processed += 1

      line = sanitize(line)
      next if line.strip.empty?

      attrs = extract_attributes(line)
      next if attrs[:dea_number].blank?

      ts = Time.current
      attrs[:created_at] ||= ts
      attrs[:updated_at] = ts

      buffer << attrs

      if buffer.size >= BATCH_SIZE
        flush!(buffer)
        buffer.clear
      end

      if (processed % PROGRESS_EVERY).zero?
        redis.multi do |r|
          r.hset(key, "processed", processed)
          r.hset(key, "last_update", Time.current.to_i)
        end
      end
    end

    flush!(buffer) if buffer.any?

    redis.multi do |r|
      r.hset(key, "processed", processed)
      r.hset(key, "last_update", Time.current.to_i)
    end
  end

  private

  def flush!(rows)
    DeaMasterRecord.upsert_all(rows, unique_by: :index_dea_master_records_on_dea_number)
  rescue => e
    Rails.logger.warn("[DEA IMPORT] bulk upsert failed: #{e.message}")
  end

  def sanitize(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  def safe_slice(line, range)
    line[range] || ""
  end

  def extract_attributes(line)
    raw = {}
    FIELD_MAP.each { |k, r| raw[k] = sanitize(safe_slice(line, r)).strip }

    {
      dea_number:           raw[:dea_number],
      schedules:            normalize_schedules(raw[:schedules]),
      expiration_date:      parse_date(raw[:expiration_raw]),
      business_activity:    raw[:business_activity],
      name:                 raw[:name],
      address1:             raw[:address1],
      address2:             raw[:address2],
      city:                 raw[:city],
      state:                raw[:state],
      zip:                  normalize_zip(raw[:zip]),
      status:               raw[:status],
      state_license_number: raw[:state_license_number]
    }
  end

  def normalize_schedules(s)
    s.to_s.split(" ").reject(&:blank?).join(",")
  end

  def parse_date(raw)
    raw = raw.to_s.strip
    return nil unless raw.match?(/\A\d{8}\z/)
    return nil if raw == "00000000" || raw == "99999999" || raw.start_with?("0000")
    Date.strptime(raw, "%Y%m%d")
  rescue
    nil
  end

  def normalize_zip(z)
    z.to_s.gsub(/\D/, "")[0..4]
  end
end
