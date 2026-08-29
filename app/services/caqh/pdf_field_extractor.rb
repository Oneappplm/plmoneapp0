module Caqh
  class PdfFieldExtractor
    require "pdf/reader"

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def call
      reader = PDF::Reader.new(file_path)
      full_text = reader.pages.map(&:text).join("\n")

      if standard_application_pdf_text?(full_text)
        return extract_minimal_fields_from_standard_pdf(full_text)
      end

      fields = {}

      reader.pages.each do |page|
        text = page.text
        next unless text

        text.split("\n").each do |raw_line|
          line = raw_line.strip
          next if line.blank?
          next unless line.include?(":")

          scan_label_value_pairs(line).each do |label, value|
            next if label.blank? || value.blank?
            key = normalize_label(label)
            fields[key] ||= value.strip
          end
        end
      end

      fields
    end

    private

    def standard_application_pdf_text?(text)
      t = text.to_s
      t.match?(/Provider Application/i) ||
        t.match?(/Section 1\s+Personal Information and Professional IDs/i) ||
        t.match?(/Std\. App\.\s*v6\.0/i)
    end

    def extract_minimal_fields_from_standard_pdf(text)
      fields = {}

      if (id = text[/CAQH PROVIDER ID\s*:\s*(\d{8,10})/i, 1])
        fields["provider-caqh-id"] = id
      end

      if (provider = text[/Provider:\s*(.+?)\n/i, 1])
        fields["provider"] = provider.strip
      end

      if (date_generated = text[/Date Generated:\s*(\d{1,2}\/\d{1,2}\/\d{4})/i, 1])
        fields["date-generated"] = date_generated
      end

      if (last_attestation = text[/Last Attestation(?: Date)?\s*:\s*(\d{1,2}\/\d{1,2}\/\d{4})/i, 1])
        fields["last-attestation-date"] = last_attestation
      end

      fields
    end

    def scan_label_value_pairs(line)
      line.scan(/([^:]+?)\s*:\s*([^:]+?)(?=(\s+[A-Z][^:]*?:\s*|$))/)
          .map { |label, value, _| [label, value] }
    end

    def normalize_label(label)
      label.to_s
           .strip
           .downcase
           .gsub(/[^a-z0-9]+/, "-")
           .gsub(/-+/, "-")
           .gsub(/^-|-$/, "")
    end
  end
end
