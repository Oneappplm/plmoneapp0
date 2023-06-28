class AddNewColumnsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def up
    add_column :enroll_groups_details, :state_id, :integer
    add_column :enroll_groups_details, :group_number, :string
    add_column :enroll_groups_details, :effective_date, :datetime
    add_column :enroll_groups_details, :application_status, :string
    add_column :enroll_groups_details, :payor_type, :string
    add_column :enroll_groups_details, :medicare_tricare, :string
    add_column :enroll_groups_details, :payor_name, :string
    add_column :enroll_groups_details, :payor_phone, :string
    add_column :enroll_groups_details, :payor_email, :string
    add_column :enroll_groups_details, :enrollment_link, :string
    add_column :enroll_groups_details, :payor_username, :string
    add_column :enroll_groups_details, :payor_password, :string
    add_column :enroll_groups_details, :payor_question, :string
    add_column :enroll_groups_details, :payor_answer, :string
    add_column :enroll_groups_details, :portal_admin, :string
    add_column :enroll_groups_details, :portal_admin_name, :string
    add_column :enroll_groups_details, :portal_admin_phone, :string
    add_column :enroll_groups_details, :portal_admin_email, :string
    add_column :enroll_groups_details, :caqh_payer, :string
    add_column :enroll_groups_details, :eft, :string
    add_column :enroll_groups_details, :era, :string
    add_column :enroll_groups_details, :client_notes, :string
    add_column :enroll_groups_details, :notes, :string
  end

  def down
    remove_column :enroll_groups_details, :state_id, :integer
    remove_column :enroll_groups_details, :group_number, :string
    remove_column :enroll_groups_details, :effective_date, :datetime
    remove_column :enroll_groups_details, :application_status, :string
    remove_column :enroll_groups_details, :payor_type, :string
    remove_column :enroll_groups_details, :medicare_tricare, :string
    remove_column :enroll_groups_details, :payor_name, :string
    remove_column :enroll_groups_details, :payor_phone, :string
    remove_column :enroll_groups_details, :payor_email, :string
    remove_column :enroll_groups_details, :enrollment_link, :string
    remove_column :enroll_groups_details, :payor_username, :string
    remove_column :enroll_groups_details, :payor_password, :string
    remove_column :enroll_groups_details, :payor_question, :string
    remove_column :enroll_groups_details, :payor_answer, :string
    remove_column :enroll_groups_details, :portal_admin, :string
    remove_column :enroll_groups_details, :portal_admin_name, :string
    remove_column :enroll_groups_details, :portal_admin_phone, :string
    remove_column :enroll_groups_details, :portal_admin_email, :string
    remove_column :enroll_groups_details, :caqh_payer, :string
    remove_column :enroll_groups_details, :eft, :string
    remove_column :enroll_groups_details, :era, :string
    remove_column :enroll_groups_details, :client_notes, :string
    remove_column :enroll_groups_details, :notes, :string
  end
end
