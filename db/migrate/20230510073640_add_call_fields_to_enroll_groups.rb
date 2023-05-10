class AddCallFieldsToEnrollGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups, :user_id, :integer
    add_column :enroll_groups, :outreach_type, :string
  end
end
