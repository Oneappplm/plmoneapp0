class CreateTableEgdAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :egd_attempts do |t|
      t.string :attempt_date
      t.string :status
      t.string :note
      t.references :user
      t.references :enroll_groups_detail
      t.timestamps
    end
  end
end
