class CreateEnrollmentProviderDetailApplicationStatusLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :epd_logs do |t|
      t.references :enrollment_providers_detail, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
