# app/controllers/ai_queries_controller.rb

class AiQueriesController < ApplicationController
  before_action :set_records_and_input, only: [:new, :index]

  def new
  end

  def index
    _fetch_ai_results(params[:query])
    @input = params[:query]
  end

  # def create
  #   _fetch_ai_results(params[:query])
  #   render :index
  # end

  def create
    result = AiSearch::Executor.new(params[:query]).call

    @records        = result[:records]
    @columns        = result[:columns]
    @title          = result[:title]
    @license_type   = result[:license_type]

    render :results
  end
  
  private

  # -----------------------------
  # Setup
  # -----------------------------
  def set_records_and_input
    @records = []
    @input = ""
    @display_specific_license_column = nil
    @license_type = nil
  end

  # -----------------------------
  # Main AI Query Handler
  # -----------------------------
  def _fetch_ai_results(query_string)
    @input = query_string
    return if @input.blank?

    normalized_input = @input.to_s.downcase

    show_all_dea =
      normalized_input.include?("all") &&
      normalized_input.include?("expired") &&
      normalized_input.include?("dea")

    current_year = Date.current.year

    requested_year =
      normalized_input[/\b(20\d{2})\b/, 1]&.to_i

    expired_requested = normalized_input.include?("expired")

    future_year_with_expired =
      expired_requested &&
      requested_year.present? &&
      requested_year > current_year


    raw_response = ChatGptService.new.ask(@input)
    Rails.logger.info("ChatGPT raw response: #{raw_response}")

    begin
      @result = JSON.parse(raw_response)
    rescue JSON::ParserError
      Rails.logger.error("ChatGPT returned non-JSON: #{raw_response}")
      @result = {}
      return
    end

    model_name = extract_model_name(@result)
    return unless model_name

    model = model_name.safe_constantize
    return unless model

    conditions_hash = @result["conditions"] || @result["params"] || {}
    joins_clause    = @result["joins"]

    # 🔹 NEW: detect license type once per query
    @license_type = detect_license_type(@result)

    # 🔹 Existing logic
    @display_specific_license_column = determine_display_column(conditions_hash)
    conditions = normalize_conditions(conditions_hash)

    base_query = model.all
    base_query = base_query.joins(joins_clause) if joins_clause.present?

    # ✅ SHORT-CIRCUIT: "all expired dea licenses"
    if show_all_dea
      @records = base_query.distinct
      @license_type = "DEA License"
      return
    end

    if future_year_with_expired && conditions_hash.dig("provider_deas", "expiration_date")
      conditions_hash["provider_deas"]["expiration_date"].delete("lt")
      conditions_hash["provider_deas"]["expiration_date"].delete("lte")
    end

    begin
      @q = base_query.ransack(params[:q])
      @records = @q.result.where(conditions)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("AI Query Error: #{e.message}")
      @records = []
      flash.now[:alert] = "Your query referred to a field or relation that doesn’t exist."
    rescue => e
      Rails.logger.error("Unexpected AI error: #{e.message}")
      @records = []
      flash.now[:alert] = "Something went wrong while processing your query."
    end
  end

  # -----------------------------
  # 🔹 LICENSE TYPE DETECTION
  # -----------------------------
  def detect_license_type(result)
    joins      = result["joins"].to_s
    conditions = result["conditions"] || {}

    return "DEA License" if joins.include?("provider_deas")
    return "Board Certification" if joins.include?("board_certifications")

    if conditions.keys.any? { |k| k.to_s.include?("license_expiration_date") }
      return "State License"
    end

    "Unknown License"
  end

  # -----------------------------
  # Helpers
  # -----------------------------
  def extract_model_name(result)
    if result["command"] == "find" && result["resource"].present?
      result["resource"].classify
    elsif result["action"] == "index" && result["resource"].present?
      result["resource"].classify
    end
  end

  def determine_display_column(conditions_hash)
    return nil unless conditions_hash.is_a?(Hash)
    return nil unless conditions_hash.keys.count == 1

    top_key = conditions_hash.keys.first.to_s

    if top_key.ends_with?("_expiration_date") || top_key.ends_with?("_effective_date")
      return top_key.to_sym
    end

    nested = conditions_hash[top_key]
    if nested.is_a?(Hash) && nested.keys.count == 1
      nested_key = nested.keys.first.to_s
      if nested_key.ends_with?("_expiration_date") || nested_key.ends_with?("_effective_date")
        return nested_key.to_sym
      end
    end

    nil
  end

  # -----------------------------
  # Date Normalization
  # -----------------------------
  def normalize_conditions(raw_conditions)
    require "chronic"
    Chronic.time_class = Time.zone

    normalized = {}

    raw_conditions.each do |key, value|
      if value.is_a?(Hash)
        # Operator-based condition
        value.each do |operator, raw_val|
          parsed = parse_gemini_date_value(raw_val)
          next unless parsed

          case operator.to_s
          when "lt"
            normalized[key.to_sym] = ..parsed.end_of_day
          when "lte"
            normalized[key.to_sym] = ..parsed.end_of_day
          when "gt"
            normalized[key.to_sym] = parsed.beginning_of_day..
          when "gte"
            normalized[key.to_sym] = parsed.beginning_of_day..
          end
        end
      else
        normalized[key.to_sym] = value
      end
    end

    normalized
  end



  def parse_gemini_date_value(value)
    value = value.to_s.strip.downcase

    case value
    when /\Alast\s+(\d+)\s+days\z/
      $1.to_i.days.ago.in_time_zone
    when /\A(\d+)\.days\.ago\z/, /\A(\d+)\s+days\s+ago\z/
      $1.to_i.days.ago.in_time_zone
    when "today"
      Time.zone.today.in_time_zone
    when "yesterday"
      1.day.ago.in_time_zone
    else
      Chronic.parse(value)
    end
  end
end
