class AddExtractedDataToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :extracted_data, :jsonb
    add_index  :provider_personal_informations, :extracted_data, using: :gin
  end
end
