# frozen_string_literal: true

class CreateProviderSsnVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_ssn_verifications do |t|
      t.bigint :provider_personal_information_id, null: false
      t.bigint :provider_attest_id
      t.bigint :verified_by_id

      t.string :status, null: false
      t.string :ssn_last_four, limit: 4

      t.boolean :ssn_matched, default: false, null: false
      t.boolean :first_name_matched
      t.boolean :middle_name_matched
      t.boolean :last_name_matched
      t.boolean :date_of_birth_matched

      t.integer :matched_record_count, default: 0, null: false

      t.date :death_date
      t.datetime :source_date

      t.jsonb :verification_details, default: {}, null: false

      t.datetime :verified_at
      t.text :error_message

      t.timestamps
    end

    add_index(
      :provider_ssn_verifications,
      :provider_personal_information_id,
      name: "index_ssn_verifications_on_provider_info"
    )

    add_index :provider_ssn_verifications, :provider_attest_id
    add_index :provider_ssn_verifications, :verified_by_id
    add_index :provider_ssn_verifications, :status
    add_index :provider_ssn_verifications, :verified_at
  end
end