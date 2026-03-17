# app/services/dea_master_importer.rb
class DeaMasterImporter
  BATCH_SIZE = 2000

  # update progress frequently by bytes (so UI moves on huge file)
  BYTES_PROGRESS_EVERY = 2 * 1024 * 1024 # 2MB

  def initialize(file_path, job_id)
    @file_path = file_path
    @job_id    = job_id
  end

  def import!
    redis = $redis
    key   = "dea_import:#{@job_id}"

    total_bytes = File.size(@file_path).to_i
    redis.hset(key, "total_bytes", total_bytes)

    processed = 0
    bytes_read = 0
    next_progress_at = BYTES_PROGRESS_EVERY

    buffer = []
    now = Time.current

    File.open(@file_path, "rb") do |io|
      io.each_line do |line|
        processed += 1
        bytes_read += line.bytesize

        line = sanitize(line)
        next if line.strip.empty?

        attrs = extract_attributes(line)
        next if attrs[:dea_number].blank?

        attrs[:created_at] ||= now
        attrs[:updated_at] = now
        buffer << attrs

        if buffer.size >= BATCH_SIZE
          flush!(buffer)
          buffer.clear
        end

        # ✅ frequent bytes progress
        if bytes_read >= next_progress_at
          # estimate total lines using average bytes/line so far
          avg = (bytes_read.to_f / processed)
          est_total = avg > 0 ? (total_bytes / avg).to_i : 0

          redis.pipelined do |r|
            r.hset(key, "processed", processed)
            r.hset(key, "bytes_read", bytes_read)
            r.hset(key, "total", est_total) if est_total > 0
            r.hset(key, "status", "running")
            r.hset(key, "last_update", Time.current.to_i)
          end

          next_progress_at = bytes_read + BYTES_PROGRESS_EVERY
        end
      end
    end

    flush!(buffer) if buffer.any?

    redis.pipelined do |r|
      r.hset(key, "processed", processed)
      r.hset(key, "bytes_read", total_bytes)
      r.hset(key, "status", "finished")
      r.hset(key, "last_update", Time.current.to_i)
    end
  end

  private

  # ---- your existing field map/extract helpers go here ----
  FIELD_MAP = {
    dea_number: 0..10,
    schedules: 11..27,
    expiration_raw: 28..35,
    business_activity: 36..71,
    name: 72..107,
    address1: 108..143,
    address2: 144..179,
    city: 180..215,
    state: 216..217,
    zip: 218..226,
    status: 227..236,
    state_license_number: 237..270
  }.freeze

  def flush!(rows)
    DeaMasterRecord.upsert_all(rows, unique_by: :index_dea_master_records_on_dea_number)
  rescue => e
    Rails.logger.warn("DEA bulk upsert failed: #{e.message}")
  end

  def sanitize(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  def safe_slice(line, range)
    return "" unless line && range
    line[range] || ""
  end

  def extract_attributes(line)
    raw_vals = {}
    FIELD_MAP.each { |k, r| raw_vals[k] = sanitize(safe_slice(line, r)).strip }

    {
      dea_number: raw_vals[:dea_number],
      schedules: raw_vals[:schedules].to_s.split(" ").reject(&:blank?).join(","),
      expiration_date: parse_date(raw_vals[:expiration_raw]),
      business_activity: raw_vals[:business_activity],
      name: raw_vals[:name],
      address1: raw_vals[:address1],
      address2: raw_vals[:address2],
      city: raw_vals[:city],
      state: raw_vals[:state],
      zip: raw_vals[:zip].to_s.gsub(/\D/, "")[0..4],
      status: raw_vals[:status],
      state_license_number: raw_vals[:state_license_number]
    }
  end

  def parse_date(raw)
    raw = raw.to_s.strip
    return nil unless raw.match?(/\A\d{8}\z/)
    return nil if raw == "00000000" || raw == "99999999" || raw.start_with?("0000")
    Date.strptime(raw, "%Y%m%d")
  rescue
    nil
  end
end
