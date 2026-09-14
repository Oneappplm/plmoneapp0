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
    # Build an attributes hash for a given AR model class using AI.
    # ADDED: full_pdf_text parameter for supplementary context.
    def attributes_for(model_class, full_pdf_text: nil)
      columns = model_class.columns_hash.transform_values { |c| c.type.to_s }

      prompt = <<~PROMPT
        You are helping a Ruby on Rails application map raw PDF-extracted fields
        to database columns for the model #{model_class.name}.

        You are given:

        1) RAW_FIELDS: a flat hash of key/value pairs extracted from a CAQH provider PDF.
           Keys are noisy field labels from the PDF, values are strings.

        2) SCHEMA: the database columns for the #{model_class.table_name} table
           with their data types.

        3) FULL_TEXT: The complete, raw text extracted from the PDF. Use this as
           a secondary source ONLY to find values for SCHEMA columns that were not
           found in RAW_FIELDS (e.g., 'birth_date', 'ssn', etc.).

        Your task:
        - Examine RAW_FIELDS, SCHEMA, and FULL_TEXT.
        - Decide which values should populate which SCHEMA columns for the #{model_class.name} record.
        - Only use column names that exist in SCHEMA.
        - **If you're not sure, omit the column.**
        - **Do NOT invent values.**

        OUTPUT FORMAT (IMPORTANT):
        - Output a single JSON object.
        - Keys MUST be column names from SCHEMA.
        - Values should be strings (dates as strings are fine).
        - Do NOT wrap the JSON in ``` fences.
        - Do NOT include any explanation, only JSON.

        RAW_FIELDS (as JSON):
        #{raw_fields.to_json}

        SCHEMA (as JSON: column_name => type):
        #{columns.to_json}

        FULL_TEXT (for context and finding missing data - truncated to 10k chars):
        --- START FULL TEXT ---
        #{full_pdf_text.to_s.truncate(10000)}
        --- END FULL TEXT ---

        Now output ONLY the JSON object of column_name => value for #{model_class.name}.
      PROMPT

      response = OPENAI_CLIENT.chat(
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
