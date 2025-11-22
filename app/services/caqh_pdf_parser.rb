class CaqhPdfParser
  LABEL_REGEX = /
    (?<!\S)                                 # label starts at word boundary (not necessarily new line)
    ([A-Za-z0-9\-\&\(\)\/\.\' ]{2,120}?)     # liberal label
    \s*:\s*                                 # colon separator
  /x

  def self.parse(text)
    t = text.gsub("\r", "\n")
    matches = []

    t.to_enum(:scan, LABEL_REGEX).each do
      m = Regexp.last_match
      matches << { label: m[1].strip, start_pos: m.end(0) }
    end

    return parse_linewise(t) if matches.empty?

    result = {}
    matches.each_with_index do |entry, idx|
      label = entry[:label]
      value_start = entry[:start_pos]

      # find the next label start
      next_label_pos =
        if matches[idx + 1]
          matches[idx + 1][:start_pos] - (matches[idx + 1][:label].length + 1)
        else
          t.length
        end

      raw_value = t[value_start...next_label_pos] || ""
      cleaned = clean_value(raw_value)

      cleaned = cleaned.gsub(/\b#{Regexp.escape(label)}\b\s*:\s*/i, "").strip

      key = normalize_key(label)
      result[key] = cleaned unless cleaned.empty?
    end

    result
  end

  def self.parse_linewise(text)
    result = {}
    text.each_line do |line|
      next if line.strip.empty?
      if line =~ /^(.+?)\s*:\s*(.+)$/
        key = normalize_key($1)
        result[key] = clean_value($2)
      end
    end
    result
  end

  def self.normalize_key(key)
    key.to_s.downcase.gsub(/[:\(\)\/\\\.\-]/, " ")
       .gsub(/[^\w\s]/, "")
       .squeeze(" ")
       .strip
       .gsub(/\s+/, "_")
  end

  def self.clean_value(val)
    val.to_s.gsub(/\u00A0/, " ").gsub(/\s+/, " ").strip
  end
end
