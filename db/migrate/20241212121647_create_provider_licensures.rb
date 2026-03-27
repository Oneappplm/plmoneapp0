class CreateProviderLicensures < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_licensures do |t|
      t.integer :state_id
      t.string :license_type
      t.string :license_number
      t.date :license_issue_date
      t.date :license_expiration_date
      t.references :provider_attest, null: false, foreign_key: true
      t.integer :caqh_provider_attest_id
      t.boolean :currently_practice_under_this
      t.boolean :is_primary_license
      t.boolean :level_require_supervision
      t.boolean :failed_state_license_exam
      t.string :license_person_type
      t.text :license_comment
      t.boolean :show_on_tickler

      t.timestamps
    end
  end
end
