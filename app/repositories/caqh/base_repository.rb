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
    object = model.find_or_initialize_by(primary_foreign_keys(row, primary_foreign_key_names))
    
    # Assign attributes to the object from the CSV row, excluding primary foreign keys and using any key replacements
    object.assign_attributes_from_csv_row(row, exclude_keys: primary_foreign_key_names, keys_replacement: keys_replacement)
    
    # Save the object to the database
    object.save
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
    hash[key.snake_case.to_s] = row[key]
   end
  
   # Return the hash containing the primary foreign keys
   hash
  end
end
