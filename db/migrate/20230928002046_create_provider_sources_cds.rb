class CreateProviderSourcesCds < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources_cds do |t|
      t.references :provider_source
      t.string :registration_number
      t.string :state
      t.datetime :issue_date
      t.datetime :expiration_date
      t.string :practicing_in_state
      t.string :full_schedule
      t.text :no_cds_explanation

      t.timestamps
    end
  end
end
