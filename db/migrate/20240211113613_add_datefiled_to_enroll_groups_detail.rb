class AddDatefiledToEnrollGroupsDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :date, :datetime
    add_column :enroll_groups_details, :attempt_status, :string
    add_column :enroll_groups_details, :note, :string
    add_column :enroll_groups_details, :agent_user_id, :integer
  end
end
