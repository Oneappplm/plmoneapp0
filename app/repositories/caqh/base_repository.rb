# frozen_string_literal: true

class Caqh::BaseRepository < ApplicationService
  attr_reader :row, :model, :primary_foreign_key_names, :keys_replacement

  def initialize(row, model, keys_replacement = {}, headers_limit: 2)
    @row                       = row
    @model                     = model.constantize
    @primary_foreign_key_names = row.headers.first(headers_limit)
    @keys_replacement          = keys_replacement
  end

  def call
   ActiveRecord::Base.transaction do
    # Find an existing object or initialize a new one using the primary foreign keys from the CSV row
    # 'model_class' is assumed to be the class of the object being worked with
    # 'primary_foreign_keys' returns a hash of primary foreign keys derived from the CSV row
    provider_attest = ProviderAttest.first_or_create(provider_attest_id: row["ProviderAttestID"])

    object = model.find_or_initialize_by(primary_foreign_keys(row, model::PRIMARY_KEY_ROW_NAMES))
    Rails.logger.info('haysss')
    Rails.logger.info(model)
    # Assign attributes to the object from the CSV row, excluding primary foreign keys and using any key replacements
    object.assign_attributes_from_csv_row(row, exclude_keys: model::PRIMARY_KEY_ROW_NAMES, keys_replacement: keys_replacement)
    Rails.logger.info(object.inspect)
    Rails.logger.info(object.valid?)
    Rails.logger.info(object.errors.full_messages)
    # Save the object to the database
    object.save!
   end
  end

  protected
  def primary_foreign_keys(row, keys = [])
   # Return an empty hash if the keys array is empty
   return {} unless keys.size != 0
  
   # Initialize an empty hash to store the primary foreign keys
   hash = {}
  
   # Iterate through each key in the keys array
   keys.each do |key|
    # Convert the key to a snake_case string and set its value from the row
    Rails.logger.info("keys")
    Rails.logger.info(row)
    Rails.logger.info(key.snake_case.to_s)
    hash[key.snake_case.to_s] = row[key]
    Rails.logger.info(row[key])
    Rails.logger.info(hash[key.snake_case.to_s])
   end
  
   # Return the hash containing the primary foreign keys
   hash
  end
end
