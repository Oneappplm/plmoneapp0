# app/services/caqh/ai_field_mapper.rb
module Caqh
  class AiFieldMapper
    attr_reader :raw_fields

    def initialize(raw_fields)
      @raw_fields = raw_fields
    end

    # Build an attributes hash for a given AR model class using AI.
    #
    # Example:
    #   mapper = Caqh::AiFieldMapper.new(raw_fields)
    #   attrs  = mapper.attributes_for(ProviderPersonalInformation)
    #
    # Returns a plain Ruby hash: { "first_name" => "Alan", "last_name" => "Xia", ... }
    def attributes_for(model_class)
      columns = model_class.columns_hash.transform_values { |c| c.type.to_s }

      prompt = <<~PROMPT
        You are helping a Ruby on Rails application map raw PDF-extracted fields
        to database columns for the model #{model_class.name}.

        You are given:

        1) RAW_FIELDS: a flat hash of key/value pairs extracted from a CAQH provider PDF.
           Keys are noisy field labels from the PDF, values are strings.
           Example keys: "first-name", "personal-e-mail-address", "license-state", etc.

        2) SCHEMA: the database columns for the #{model_class.table_name} table
           with their data types.

        Your task:
        - Examine RAW_FIELDS and SCHEMA.
        - Decide which RAW_FIELDS values should populate which SCHEMA columns
          for the #{model_class.name} record.
        - Only use column names that exist in SCHEMA.
        - If you're not sure about a column, omit it instead of guessing.
        - Do NOT invent values.

        OUTPUT FORMAT (IMPORTANT):
        - Output a single JSON object.
        - Keys MUST be column names from SCHEMA (e.g. "first_name", "last_name", "address_line1").
        - Values should be strings (dates as strings are fine; we will cast them in Ruby).
        - Do NOT wrap the JSON in ``` fences.
        - Do NOT include any explanation, only JSON.

        RAW_FIELDS (as JSON):
        #{raw_fields.to_json}

        SCHEMA (as JSON: column_name => type):
        #{columns.to_json}

        Now output ONLY the JSON object of column_name => value for #{model_class.name}.
      PROMPT

      response = OpenAI_CLIENT.chat(
        parameters: {
          model: "gpt-4.1-mini",
          # If supported by your gem, uncomment this to force JSON:
          # response_format: { type: "json_object" },
          messages: [
            { role: "system", content: "You map raw CAQH PDF fields to Rails model attributes using the given schema." },
            { role: "user",   content: prompt }
          ],
          temperature: 0.1
        }
      )

      content = response.dig("choices", 0, "message", "content") || "{}"
      parse_json(content)
    rescue Faraday::TooManyRequestsError => e
      Rails.logger.error("Rate limited in AiFieldMapper: #{e.message}")
      {}
    end

    private

    def parse_json(str)
      cleaned = str.to_s.strip
      cleaned = cleaned.sub(/\A```json/i, "").sub(/\A```/, "")
      cleaned = cleaned.sub(/``` \z/, "").sub(/```\z/, "").strip

      unless cleaned.match?(/\A\{.*\}\z/m)
        first_brace = cleaned.index("{")
        last_brace  = cleaned.rindex("}")
        cleaned = cleaned[first_brace..last_brace] if first_brace && last_brace && last_brace > first_brace
      end

      JSON.parse(cleaned)
    rescue JSON::ParserError => e
      Rails.logger.error("AiFieldMapper JSON parse error: #{e.message}")
      Rails.logger.error("Raw AI content was:\n#{str.inspect}")
      {}
    end
  end
end
