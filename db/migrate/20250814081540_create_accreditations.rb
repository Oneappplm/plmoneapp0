class CreateAccreditations < ActiveRecord::Migration[7.0]
  def change
    create_table :accreditations do |t|
      t.bigint :provider_attest_id
      t.string :accrediting_body
      t.date :initial_review_date
      t.date :last_review_date
      t.string :certification_number
      t.date :expiration_date
      t.boolean :does_not_expire
      t.boolean :primary_accrediting_body
      t.boolean :corrective_action_plan
      t.date :date_initiated
      t.date :date_completed
      t.text :comments
      t.boolean :show_on_tickler

      t.timestamps
    end
      add_index :accreditations, :provider_attest_id, name: "index_accreditations_on_provider_attest_id"
  end
end
