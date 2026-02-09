# app/services/ai_search/intent_parser.rb

module AiSearch
  class IntentParser
    attr_reader :query

    def initialize(query)
      @query = query.to_s.downcase.strip
    end

    def call
      {
        entity: detect_entity,
        filter: detect_filter,
        license_type: detect_license_type,
        year: detect_year
      }
    end

    private

    def detect_year
      year_match = query.match(/20\d{2}/)
      year_match[0].to_i if year_match
    end


    # -----------------------------
    # ENTITY DETECTION (ORDER MATTERS)
    # -----------------------------
    def detect_entity
      case query
      when /\bdea\b/
        :dea
      when /\bboard\b/
        :board_certification
      when /\blicen[cs]e\b|\blicensure\b/
        :licenses
      when /\busers?\b/
        :users
      else
        :providers
      end
    end

    def dea_keywords?
      query.include?("dea")
    end

    def board_keywords?
      query.include?("board")
    end

    def state_license_keywords?
      query.match?(/\blicen[cs]e\b|\blicensure\b/) &&
        !dea_keywords? &&
        !board_keywords?
    end

    def user_keywords?
      query.include?("user")
    end

    # -----------------------------
    # FILTER DETECTION
    # -----------------------------
    def detect_filter
      return :expired if query.include?("expired")
      return :expiring_soon if expiring_soon_keywords?
      return :active if query.include?("active")

      :all
    end

    def expiring_soon_keywords?
      query.include?("expiring soon") ||
        query.include?("expiring") ||
        query.include?("next 30") ||
        query.include?("next 60") ||
        query.include?("next 90")
    end

    # -----------------------------
    # LICENSE TYPE (For Display Column)
    # -----------------------------
    def detect_license_type
      return "DEA License" if dea_keywords?
      return "Board Certification" if board_keywords?
      return "State License" if state_license_keywords?

      nil
    end
  end
end
