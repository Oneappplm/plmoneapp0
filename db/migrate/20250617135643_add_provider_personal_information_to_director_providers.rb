class AddProviderPersonalInformationToDirectorProviders < ActiveRecord::Migration[7.0]
  def change
    add_reference :director_providers, :provider_personal_information, foreign_key: true
  end
end
