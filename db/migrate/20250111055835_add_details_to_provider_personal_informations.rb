class AddDetailsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations do |t|
      t.string :gender
      t.date :date_of_birth
      t.string :practitioner_type
      t.date :credentials_committee_date
      t.date :client_batch_date
      t.string :availability
      t.string :client_batch_name
      t.integer :client_batch_id
      t.string :market
      t.string :status
      t.string :application_method
    end
  end
end
