class CreateEnrollmentGroupsContactDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_groups_contact_details do |t|
      t.references :enrollment_group
      t.string :group_personnel_name
      t.string :group_personnel_email
      t.string :group_personnel_phone_number
      t.string :group_personnel_fax_number
      t.string :group_personnel_position
      t.timestamps
    end
  end
end
