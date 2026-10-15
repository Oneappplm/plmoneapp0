# app/services/caqh/pdf_field_extractor.rb
module Caqh
  class PdfFieldExtractor
    require "pdf/reader"

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def call
      fields = {}

      reader = PDF::Reader.new(file_path)
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

    # Handles multiple pairs on one line, e.g.
    # "First Name : James  Middle Name : Robert  Last Name : Powell  Suffix : Jr"
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
