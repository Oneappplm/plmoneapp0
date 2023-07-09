class CreateEnrollmentPayers < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_payers do |t|
      t.string :name
      t.timestamps
    end
  end
end
