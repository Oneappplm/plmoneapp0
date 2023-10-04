class CreateProviderSourcesDeas < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources_deas do |t|
      t.references :provider_source
      t.string :registration_number
      t.string :state
      t.date    :issue_date
      t.date    :expiration_date
      t.string  :full_schedule
      t.string  :does_not_expire
      t.text    :schedule_limit_explanation
      t.string  :schedule_helds

      t.timestamps
    end
  end
end
