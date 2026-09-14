class AddNpiSourceDateToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :npi_source_date, :date
  end
end
