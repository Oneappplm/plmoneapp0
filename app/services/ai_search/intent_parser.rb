# app/services/ai_search/intent_parser.rb

module AiSearch
  class IntentParser
    attr_reader :query

    def initialize(query)
      @original_query = query.to_s.strip
      @query = @original_query.downcase
    end

    def call
      {
        entity: detect_entity,
        filter: detect_filter,
        license_type: detect_license_type,
        year: detect_year,
        state: detect_state
      }
    end

    STATE_MAP = {
      "fl" => "Florida",
      "ca" => "California",
      "tx" => "Texas",
      "ny" => "New York",
      "nj" => "New Jersey"
    }.freeze

    STOPWORDS = %w[
      in on at for from to by with without of and or
    ].freeze


    private

    def detect_year
      year_match = query.match(/20\d{2}/)
      year_match[0].to_i if year_match
    end

    # ENTITY DETECTION (ORDER MATTERS)
    def detect_entity
      case query
      when /\bdea\b/
        :dea
      when /\bboard\b/
        :board_certification
      when /\bstate\s+licen[cs]es?\b|\blicen[cs]es?\b|\blicensure\b/
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

    # FILTER DETECTION
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

    # LICENSE TYPE (For Display Column)
    def detect_license_type
      return "DEA License" if dea_keywords?
      return "Board Certification" if board_keywords?
      return "State License" if state_license_keywords?

      nil
    end

    def detect_state
      tokens = @original_query.split(/\W+/)

      tokens.each do |token|
        next if STOPWORDS.include?(token.downcase)

        # Accept uppercase abbreviations (FL)
        if token.length == 2 && token == token.upcase
          state = AiSearch::StateNormalizer.normalize(token)
          return state if state.present?
        end

        # Accept lowercase abbreviations ONLY if explicitly mapped (fl, ca, tx)
        if token.length == 2 && STATE_MAP.key?(token.downcase)
          return token.upcase
        end
      end

      # Multi-word states (e.g. "Florida", "New York")
      AiSearch::StateNormalizer::STATES.each do |name, abbr|
        return abbr if query.include?(name)
      end

      nil
    end


  end
end
