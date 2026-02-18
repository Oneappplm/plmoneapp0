# app/services/ai_search/state_normalizer.rb

module AiSearch
  class StateNormalizer
    STATES = {
      "alabama" => "AL",
      "alaska" => "AK",
      "arizona" => "AZ",
      "arkansas" => "AR",
      "california" => "CA",
      "colorado" => "CO",
      "connecticut" => "CT",
      "delaware" => "DE",
      "florida" => "FL",
      "georgia" => "GA",
      "hawaii" => "HI",
      "idaho" => "ID",
      "illinois" => "IL",
      "indiana" => "IN",
      "iowa" => "IA",
      "kansas" => "KS",
      "kentucky" => "KY",
      "louisiana" => "LA",
      "maine" => "ME",
      "maryland" => "MD",
      "massachusetts" => "MA",
      "michigan" => "MI",
      "minnesota" => "MN",
      "mississippi" => "MS",
      "missouri" => "MO",
      "montana" => "MT",
      "nebraska" => "NE",
      "nevada" => "NV",
      "new hampshire" => "NH",
      "new jersey" => "NJ",
      "new mexico" => "NM",
      "new york" => "NY",
      "north carolina" => "NC",
      "north dakota" => "ND",
      "ohio" => "OH",
      "oklahoma" => "OK",
      "oregon" => "OR",
      "pennsylvania" => "PA",
      "rhode island" => "RI",
      "south carolina" => "SC",
      "south dakota" => "SD",
      "tennessee" => "TN",
      "texas" => "TX",
      "utah" => "UT",
      "vermont" => "VT",
      "virginia" => "VA",
      "washington" => "WA",
      "west virginia" => "WV",
      "wisconsin" => "WI",
      "wyoming" => "WY"
    }.freeze

    REVERSE = STATES.invert.freeze

    def self.normalize(input)
      return nil if input.blank?

      value = input.to_s.strip.downcase

      # If abbreviation (FL)
      return value.upcase if REVERSE.key?(value.upcase)

      # If full name (Florida)
      STATES[value]
    end
  end
end
