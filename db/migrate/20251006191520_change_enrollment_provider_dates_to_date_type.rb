class ChangeEnrollmentProviderDatesToDateType < ActiveRecord::Migration[7.0]
  def up
    # List of columns to convert from string to date
    string_columns = [
      :enrollment_effective_date,
      :association_start_date,
      :business_end_date,
      :association_end_date,
      :processing_date,
      :terminated_date
    ]

    string_columns.each do |col|
      # Convert string -> date safely
      # 1. Add temporary column
      add_column :enrollment_providers_details, "#{col}_tmp", :date

      # 2. Copy valid dates into tmp column
      EnrollmentProvidersDetail.reset_column_information
      EnrollmentProvidersDetail.find_each do |record|
        next if record[col].blank?

        begin
          record.update_column("#{col}_tmp", Date.parse(record[col]))
        rescue ArgumentError
          # Skip invalid date strings
          next
        end
      end

      # 3. Remove old column
      remove_column :enrollment_providers_details, col

      # 4. Rename tmp column to original name
      rename_column :enrollment_providers_details, "#{col}_tmp", col
    end
  end

  def down
    string_columns = [
      :enrollment_effective_date,
      :association_start_date,
      :business_end_date,
      :association_end_date,
      :processing_date,
      :terminated_date
    ]

    string_columns.each do |col|
      add_column :enrollment_providers_details, "#{col}_tmp", :string
      EnrollmentProvidersDetail.reset_column_information
      EnrollmentProvidersDetail.find_each do |record|
        record.update_column("#{col}_tmp", record[col].to_s) if record[col].present?
      end
      remove_column :enrollment_providers_details, col
      rename_column :enrollment_providers_details, "#{col}_tmp", col
    end
  end
end
