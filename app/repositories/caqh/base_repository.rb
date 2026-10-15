# frozen_string_literal: true

class Caqh::BaseRepository < ApplicationService
  attr_reader :row, :model, :primary_foreign_key_names, :keys_replacement

  def initialize(row, model, keys_replacement = {}, headers_limit: 2)
    @row                       = row
    @model                     = model.constantize
    @primary_foreign_key_names = row.headers.first(headers_limit)
    @keys_replacement          = keys_replacement

    # Preload or create ProviderAttest early
    if row["ProviderAttestID"].present?
      @provider_attest = ProviderAttest.find_or_create_by(
        caqh_provider_attest_id: row["ProviderAttestID"]
      )
    end
  end

  def call
    ActiveRecord::Base.transaction do
      # Stop if any primary keys are missing or not digits
      return if model::PRIMARY_KEY_ROW_NAMES.map { |key| row[key] =~ /\A\d+\Z/ }.include?(nil)

      object = model.find_or_initialize_by(primary_foreign_keys(row, model::PRIMARY_KEY_ROW_NAMES))

      # Assign all non-primary fields
      object.assign_attributes_from_csv_row(
        row,
        exclude_keys: model::PRIMARY_KEY_ROW_NAMES,
        keys_replacement: keys_replacement
      )

      # Ensure provider_attest_id is assigned automatically
      if @provider_attest.present? && object.respond_to?(:provider_attest_id)
        object.provider_attest_id = @provider_attest.id
      end

      begin
        object.save!
      rescue => e
        Rails.logger.error "🔥 ERROR saving #{model} record"
        Rails.logger.error "➡️ MESSAGE: #{e.message}"
        Rails.logger.error "➡️ ROW DATA: #{row.to_h}"
        Rails.logger.error "➡️ ATTRIBUTES: #{object.attributes}"
        Rails.logger.error "➡️ BACKTRACE: #{e.backtrace.first(10)}"
        raise
      end
    end
  end

  protected

  def primary_foreign_keys(row, keys = [])
    return {} if keys.empty?

    keys.each_with_object({}) do |key, hash|
      hash["caqh_#{key.snake_case}"] = row[key]
    end
  end
end
