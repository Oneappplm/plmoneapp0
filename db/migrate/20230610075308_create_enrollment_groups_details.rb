class CreateEnrollmentGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_groups_details do |t|
      t.references :enrollment_group
      t.string :individual_ownership_first_name
      t.string :individual_ownership_middle_name
      t.string :individual_ownership_last_name
      t.string :individual_ownership_title
      t.string :individual_ownership_ssn
      t.string :individual_ownership_dob
      t.string :individual_ownership_percent_of_ownership
      t.date :individual_ownership_effective_date
      t.date :individual_ownership_control_date

      t.timestamps
    end
  end
end
