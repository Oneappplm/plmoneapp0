# app/controllers/ai_queries_controller.rb
class AiQueriesController < ApplicationController
  before_action :set_records_and_input, only: [:new, :index]

  def new
  end

  def index
    _fetch_ai_results(params[:query])
    @input = params[:query]
  end

  def create
    _fetch_ai_results(params[:query])

    render :index
  end

  private


  def set_records_and_input
    @records = []
    @input = ""
    @display_specific_license_column = nil
  end

  def _fetch_ai_results(query_string)
    @input = query_string

    if @input.present?
      @result = GeminiService.ask(@input)

      model_name = extract_model_name(@result)

      if model_name
        model = model_name.safe_constantize
        if model
          conditions_hash = @result["conditions"] || @result["params"] || {}

          @display_specific_license_column = determine_display_column(conditions_hash)

          joins_clause = @result["joins"]
          conditions = normalize_conditions(conditions_hash)

          base_query = model.all
          base_query = base_query.joins(joins_clause.to_sym) if joins_clause.present?

          @q = base_query.ransack(params[:q])
          @records = @q.result.where(conditions).paginate(per_page: 10, page: params[:page] || 1)
        end
      end
    end
  end

  def determine_display_column(conditions_hash)
    if conditions_hash.is_a?(Hash) && conditions_hash.keys.count == 1
      top_level_key = conditions_hash.keys.first.to_s

      if top_level_key.ends_with?("_expiration_date") || top_level_key.ends_with?("_effective_date")
        return top_level_key.to_sym
      elsif conditions_hash[top_level_key].is_a?(Hash) &&
            conditions_hash[top_level_key].keys.count == 1
        nested_key = conditions_hash[top_level_key].keys.first.to_s
        if nested_key.ends_with?("_expiration_date") || nested_key.ends_with?("_effective_date")
          return nested_key.to_sym
        end
      end
    end
    nil
  end

  def extract_model_name(result)
    if result["command"] == "find" && result["resource"].present?
      result["resource"].classify
    elsif result["action"] == "index" && result["resource"].present?
      result["resource"].classify
    end
  end

  def normalize_conditions(raw_conditions)
    require 'chronic'
    Chronic.time_class = Time.zone

    processed = {}

    (raw_conditions || {}).each do |key, value|
      key_sym = key.to_sym

      if value.is_a?(Hash)
        if key_sym.to_s.pluralize == key_sym.to_s && key_sym.to_s.include?('_') && value.keys.all? { |k| k.is_a?(String) || k.is_a?(Symbol) }
          processed[key_sym] = normalize_conditions(value)
        else
          value.each do |operator, val|
            parsed_val = parse_gemini_date_value(val)
            next if parsed_val.nil?

            case operator.to_s
            when "lt", "<"
              processed[key_sym] = ..parsed_val
            when "lte", "<="
              processed[key_sym] = ..parsed_val
            when "gt", ">"
              processed[key_sym] = parsed_val..
            when "gte", ">="
              processed[key_sym] = parsed_val..Time.zone.now
            else
              processed[key_sym] = val
            end
          end
        end
      else
        parsed_val = parse_gemini_date_value(value)

        if parsed_val.is_a?(Date) || parsed_val.is_a?(Time)
            processed[key_sym] = parsed_val.beginning_of_day..parsed_val.end_of_day
        else
            processed[key_sym] = parsed_val
        end
      end
    end

    processed
  end

  def parse_gemini_date_value(value)
    value = value.to_s.strip.downcase

    case value
    when /\Alast\s+(\d+)\s+days\z/
      $1.to_i.days.ago.in_time_zone
    when /\A(\d+)\.days\.ago\z/, /\A(\d+)\s+days\s+ago\z/
      $1.to_i.days.ago.in_time_zone
    when 'today'
      Time.zone.today.in_time_zone
    when 'yesterday'
      1.day.ago.in_time_zone
    else
      Chronic.parse(value)
    end
  end
end
