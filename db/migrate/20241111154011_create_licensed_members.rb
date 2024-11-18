class CreateLicensedMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :licensed_members do |t|
      t.string :licensed_member_first_name
      t.string :licensed_member_last_name
      t.string :licensed_member_middle_name
      t.string :licensed_member_suffix_name
      t.string :licensed_member_specialty
      t.string :licensed_member_is_partner
      t.string :licensed_member_is_employing_physician

      t.references :practice_information
      t.timestamps
    end
  end
end
