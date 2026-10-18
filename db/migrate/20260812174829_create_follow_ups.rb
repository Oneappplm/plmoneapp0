class CreateFollowUps < ActiveRecord::Migration[7.0]
  def change
    create_table :follow_ups do |t|
      t.references :enrollment_provider, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :notes
      t.datetime :followed_up_at
      t.date :next_follow_up_date
      t.boolean :resolution_requested, null: false, default: false
      t.integer :resolution_status, null: false, default: false
      t.bigint :approved_by_id
      t.datetime :approved_at

      t.timestamps
    end
      add_foreign_key :follow_ups,
                    :users,
                    column: :approved_by_id

      add_index :follow_ups, :next_follow_up_date
      add_index :follow_ups, :resolution_status
      add_index :follow_ups,
                [:enrollment_provider_id, :next_follow_up_date],
                name: "idx_followups_provider_next_date"
  end
end
