class CreateProviderPersonalInformationAppTrackings < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_app_trackings do |t|
      t.references :provider_personal_information, null: false, foreign_key: true, index: false
      t.string :owner
      t.string :file_status
      t.string :application_type
      t.datetime :application_receipt_date
      t.datetime :application_submitted_date
      t.datetime :verification_complete_date
      t.datetime :file_return_to_client_date
      t.datetime :application_receive_complete_date

      t.boolean :expedite
      t.text :application_comment
      t.text :other_comment

      t.timestamps
    end
    add_index  :provider_personal_information_app_trackings, :provider_personal_information_id, :name => 'ppiat_id_ppi_c'

  end
end
