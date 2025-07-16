# app/services/gemini_service.rb
require "net/http"
require "json"

class GeminiService
  API_KEY = Rails.application.credentials.dig(:gemini, :api_key)
  API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent?key=#{API_KEY}"

  def self.ask(prompt, retries = 3)
    full_prompt = <<~PROMPT
      You are an assistant that helps interpret Rails app commands.
      Always respond in this JSON format only.

      Examples of expected JSON output:

      1. To find all users:
         {
           "command": "find",
           "resource": "User",
           "multiple": true,
           "conditions": {}
         }

      2. To find users created in the last 7 days:
         {
           "command": "find",
           "resource": "User",
           "multiple": true,
           "conditions": {
             "created_at": {
               "gte": "7.days.ago"
             }
           }
         }

      3. To find users created on a specific date (e.g., July 8, 2025):
         {
           "command": "find",
           "resource": "User",
           "multiple": true,
           "conditions": {
             "created_at": "2025-07-08"
           }
         }

      4. To find providers with an expired DEA license (expiration date less than or equal to today, assuming dea_license_expiration_date is directly on Provider):
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "conditions": {
             "dea_license_expiration_date": {
               "lte": "today"
             }
           }
         }

      5. To find providers with an expired PA license:
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "conditions": {
             "pa_license_expiration_date": {
               "lte": "today"
             }
           }
         }

      6. To find providers with any expired license (you can infer the specific license type if not explicitly mentioned, or default to a common one like 'license_expiration_date'):
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "conditions": {
             "license_expiration_date": {
               "lte": "today"
             }
           }
         }
      
      7. To find providers with an expired Board Certification (expiration date less than or equal to today, this field is on an associated `ProviderBoardCertification` model, accessed via `board_certifications` association):
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "joins": "board_certifications",
           "conditions": {
             "board_certifications": {
               "bc_expiration_date": {
                 "lte": "today"
               }
             }
           }
         }

      8. To find providers with a DEA license effective on a specific date (e.g., July 1, 2024, assuming dea_license_effective_date is directly on Provider):
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "conditions": {
             "dea_license_effective_date": "2024-07-01"
           }
         }

      9. To find providers with any license effective after a specific date (e.g., January 1, 2023):
         {
           "command": "find",
           "resource": "Provider",
           "multiple": true,
           "conditions": {
             "license_effective_date": {
               "gt": "2023-01-01"
             }
           }
         }

      10. To find providers with Board Certifications effective in the last 30 days (field on associated `ProviderBoardCertification` via `board_certifications`):
          {
            "command": "find",
            "resource": "Provider",
            "multiple": true,
            "joins": "board_certifications",
            "conditions": {
              "board_certifications": {
                "bc_effective_date": {
                  "gte": "30.days.ago"
                }
              }
            }
          }

      Now interpret: "#{prompt}"
    PROMPT

    uri = URI(API_URL)
    body = {
      contents: [
        {
          role: "user",
          parts: [{ text: full_prompt }]
        }
      ]
    }

    headers = { "Content-Type" => "application/json" }

    begin
      response = Net::HTTP.post(uri, body.to_json, headers)
      if response.code.to_i == 503 && retries > 0
        puts "Gemini API overloaded. Retrying in 5 seconds... (#{retries} retries left)"
        sleep 5
        return ask(prompt, retries - 1)
      end

      parsed = JSON.parse(response.body)

      puts "==== RAW GEMINI RESPONSE ===="
      puts JSON.pretty_generate(parsed)

      raw_text = parsed.dig("candidates", 0, "content", "parts", 0, "text")
      puts "==== RAW TEXT ===="
      puts raw_text.inspect

      return {} unless raw_text.is_a?(String)

      clean_text = raw_text.gsub(/```json|```/, "").strip

      JSON.parse(clean_text)
    rescue JSON::ParserError => e
      puts "Failed to parse Gemini JSON: #{e.message}"
      {}
    rescue StandardError => e
      puts "GeminiService error: #{e.message}"
      {}
    end
  end
end