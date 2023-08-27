class CreateEnrollGroupDetailApplicationStatusLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :egd_logs do |t|
      t.references :enroll_groups_detail, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end 
  end
end
