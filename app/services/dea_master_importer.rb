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

  # >>>> Add job_id to track progress
  def initialize(file_path, job_id)
    @file_path = file_path
    @job_id = job_id
  end

  def import!
    redis = $redis      # FIX: global redis instance
    processed = 0

    total = redis.hget("dea_import:#{@job_id}", "total").to_i

    File.foreach(@file_path, encoding: "bom|utf-8") do |line|
      processed += 1

      # update progress
      if processed % 300 == 0
        redis.hset("dea_import:#{@job_id}", "processed", processed)
        redis.hset("dea_import:#{@job_id}", "last_update", Time.now.to_i)
      end

      line = sanitize(line)
      next if line.strip.empty?

      attrs = extract_attributes(line)
      upsert_record(attrs)
    end

    # final progress
    redis.hset("dea_import:#{@job_id}", "processed", processed)
    redis.hset("dea_import:#{@job_id}", "last_update", Time.now.to_i)
    redis.hset("dea_import:#{@job_id}", "status", "finished")
  end

  private

  # Encode string to UTF-8 safely and strip whitespace
  def sanitize(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  # Slice each field safely
  def safe_slice(line, range)
    return "" unless line && range
    line[range] || ""
  end

  # Extract and normalize attributes
  def extract_attributes(line)
    raw_vals = {}

    FIELD_MAP.each do |key, range|
      raw_vals[key] = sanitize(safe_slice(line, range)).strip
    end

    {
      dea_number:          raw_vals[:dea_number],
      schedules:           normalize_schedules(raw_vals[:schedules]),
      expiration_date:     parse_date(raw_vals[:expiration_raw]),
      business_activity:   raw_vals[:business_activity],
      name:                raw_vals[:name],
      address1:            raw_vals[:address1],
      address2:            raw_vals[:address2],
      city:                raw_vals[:city],
      state:               raw_vals[:state],
      zip:                 normalize_zip(raw_vals[:zip]),
      status:              raw_vals[:status],
      state_license_number: raw_vals[:state_license_number]
    }
  end

  # Convert schedules like "22N 33N 4 5" => "22N,33N,4,5"
  def normalize_schedules(s)
    s.split(" ").reject(&:blank?).join(",")
  end

  # Parse expiration date safely
  def parse_date(raw)
    return nil unless raw.present?
    raw = raw.strip

    return nil unless raw.match?(/\A\d{8}\z/)
    return nil if raw == "00000000" || raw == "99999999"
    return nil if raw.start_with?("0000")

    mm = raw[4..5].to_i
    dd = raw[6..7].to_i
    return nil if mm < 1 || mm > 12
    return nil if dd < 1 || dd > 31

    Date.strptime(raw, "%Y%m%d")
  rescue Date::Error
    nil
  end

  # Normalize zip to 5 digits
  def normalize_zip(z)
    digits = z.gsub(/\D/, "")
    digits[0..4]
  end

  # Upsert record in DB
  def upsert_record(attrs)
    rec = DeaMasterRecord.find_or_initialize_by(dea_number: attrs[:dea_number])
    rec.update!(attrs)
  rescue ActiveRecord::StatementInvalid => e
    warn "Database insert failed for DEA #{attrs[:dea_number]}: #{e.message}"
  end
end
