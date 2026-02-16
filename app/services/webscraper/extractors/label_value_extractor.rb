# app/services/webscraper/extractors/label_value_extractor.rb

# frozen_string_literal: true
require "nokogiri"

module Webscraper
  module Extractors
    class LabelValueExtractor
      def initialize(html)
        @doc = Nokogiri::HTML(html)
      end

      # Returns a hash like { "License Status" => "Clear/Active", ... }
      def extract_label_value_pairs
        pairs = {}
        pairs.merge!(from_definition_lists)
        pairs.merge!(from_tables)
        pairs.merge!(from_bootstrap_rows)
        normalize_hash(pairs)
      end

      private

      def from_definition_lists
        h = {}
        @doc.css("dl").each do |dl|
          dts = dl.css("dt")
          dds = dl.css("dd")
          dts.zip(dds).each do |dt, dd|
            next unless dt && dd
            label = dt.text.strip
            value = dd.text.strip
            h[label] = value if label.present? && value.present?
          end
        end
        h
      end

      def from_tables
        h = {}
        @doc.css("table tr").each do |tr|
          cells = tr.css("th,td").map { |c| c.text.strip }.reject(&:blank?)
          next if cells.length < 2
          label = cells[0]
          value = cells[1]
          h[label] = value if label.present? && value.present?
        end
        h
      end

      # common pattern: <div class="row"><div>Label</div><div>Value</div></div>
      def from_bootstrap_rows
        h = {}
        @doc.css(".row").each do |row|
          cols = row.css('[class*="col-"]').map { |c| c.text.strip }.reject(&:blank?)
          next if cols.length < 2
          label, value = cols[0], cols[1]
          h[label] = value if label.present? && value.present?
        end
        h
      end

      def normalize_hash(hash)
        hash.transform_keys { |k| k.gsub(/\s+/, " ").strip }
            .transform_values { |v| v.gsub(/\s+/, " ").strip }
      end
    end
  end
end