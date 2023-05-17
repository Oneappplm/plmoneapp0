class CreateEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :enroll_groups_details do |t|
      t.references :enroll_group
      t.date :start_date
      t.date :due_date
      t.string :enrollment_payer
      t.string :enrollment_type
      t.string :enrollment_status
      t.string :ptan_number
      t.date :approved_date
      t.date :revalidation_date
      t.date :revalidation_due_date
      t.text :comment

      t.timestamps
    end
  end
end
