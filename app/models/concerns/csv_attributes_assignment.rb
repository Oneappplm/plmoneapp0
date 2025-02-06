# frozen_string_literal: true

module CsvAttributesAssignment
 extend ActiveSupport::Concern

 included do
  def assign_attributes_from_csv_row(row, exclude_keys: [], keys_replacement: {})
    # Initialize an empty hash to store attributes to be assigned
    attributes = {}

    # Iterate through each key-value pair in the CSV row
    row.each do |key, value|
      # Skip this iteration if the key is in the list of excluded keys
      next if exclude_keys.include?(key) || key.blank?

      # Convert the key to snake_case format
      filtered_key = key.snake_case

      # Check if there are any replacements to be made for the filtered key
      if keys_replacement.keys.size != 0 && keys_replacement.keys.include?(filtered_key)
        # Replace the filtered key with its corresponding value from keys_replacement
        filtered_key = keys_replacement[filtered_key]
      end

      # Skip this iteration unless the class has a column with the name of the filtered key
      next unless self.class.column_names.include?(filtered_key)

      # Add the filtered key and its value to the attributes hash
      attributes[filtered_key] = value
    end

    # Assign the attributes to the current object
    self.assign_attributes(attributes)
  end
 end
end