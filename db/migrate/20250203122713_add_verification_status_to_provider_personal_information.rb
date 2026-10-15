class AddVerificationStatusToProviderPersonalInformation < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :verification_status, :string
  end
end
