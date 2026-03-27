class AddNpiVerificationStatusToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :npi_verification_status, :string
   end
end
