class CreateReviewLevelChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :review_level_changes do |t|
      t.references :provider_personal_information, null: false, foreign_key: true
      t.string :changed_by
      t.string :from_level
      t.string :to_level
      t.text :reason

      t.timestamps
    end
  end
end
