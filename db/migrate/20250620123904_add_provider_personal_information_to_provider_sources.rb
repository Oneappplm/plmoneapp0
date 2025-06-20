class AddProviderPersonalInformationToProviderSources < ActiveRecord::Migration[7.0]
  def change
    add_reference :provider_sources, :provider_personal_information, foreign_key: true
  end
end
