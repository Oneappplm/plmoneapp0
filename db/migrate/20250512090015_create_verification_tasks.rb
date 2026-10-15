class CreateVerificationTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_tasks do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.references :verification_product, null: false, foreign_key: true
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
