# app/services/chat_gpt_service.rb
require "openai"

class ChatGptService
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV.fetch("OPENAI_API_KEY"),
      project_id:  ENV["OPENAI_PROJECT_ID"]
    )
  end

  def ask(prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: <<~SYSTEM
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

              11. To list licenses expiring in a specific month and year
                 (e.g., "Licenses expiring 2/2026", "Nov 2026"):

                 - Interpret this as expiration dates between the first and last day of that month.
                 - Always convert month/year into a date range.

                 Example output for "2/2026":
                 {
                   "command": "find",
                   "resource": "Provider",
                   "multiple": true,
                   "conditions": {
                     "license_expiration_date": {
                       "gte": "2026-02-01",
                       "lte": "2026-02-28"
                     }
                   }
                 }
              12. To list licenses expiring in a full year only (e.g., "Licenses expiring in 2026"):
                - Interpret this as expiration dates between January 1 and December 31 of that year.
                - Always convert year-only input into a full date range.

                Example output:
                {
                  "command": "find",
                  "resource": "Provider",
                  "multiple": true,
                  "conditions": {
                    "license_expiration_date": {
                      "gte": "2026-01-01",
                      "lte": "2026-12-31"
                    }
                  }
                }
              13. If the user mentions DEA license, controlled substance, or DEA number:
                - Use ProviderDea
                - Join provider_deas
                - Use expiration_date (not license_expiration_date)

              Example output: 
              {
                "command": "find",
                "resource": "ProviderPersonalInformation",
                "multiple": true,
                "joins": {
                  "provider_attest": "provider_deas"
                },
                "conditions": {
                  "provider_deas": {
                    "expiration_date": {
                      "lt": "today"
                    }
                  }
                }
              }

            14. If the user says "expired" AND provides a month/year or year:
              - Treat "expired" as expiration_date < today
              - AND constrain results to the provided date range
              - BOTH filters must apply

              Example:
              {
                "command": "find",
                "resource": "ProviderPersonalInformation",
                "multiple": true,
                "joins": {
                  "provider_attest": "provider_deas"
                },
                "conditions": {
                  "provider_deas": {
                    "expiration_date": {
                      "gte": "2026-01-01",
                      "lte": "2030-12-31",
                      "lt": "today"
                    }
                  }
                }
              }

            15. If the user says "all expired" or "show all expired":
              - Treat this as a request for ALL records of that license type
              - Do NOT apply any expiration_date filter
              - Only apply joins

              Example:
              {
                "command": "find",
                "resource": "ProviderPersonalInformation",
                "multiple": true,
                "joins": {
                  "provider_attest": "provider_deas"
                },
                "conditions": {}
              }
            SYSTEM
          },
          { role: "user", content: prompt }
        ],
        temperature: 0.1
      }
    )

    response.dig("choices", 0, "message", "content").to_s
  rescue => e
    Rails.logger.error("ChatGPT error: #{e.message}")
    { error: e.message }.to_json
  end
end
