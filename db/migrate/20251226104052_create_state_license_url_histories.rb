class CreateStateLicenseUrlHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :state_license_url_histories do |t|
      t.references :state, null: false, foreign_key: true
      t.text :old_url
      t.text :new_url
      t.datetime :changed_at

      t.timestamps
    end
  end
end
