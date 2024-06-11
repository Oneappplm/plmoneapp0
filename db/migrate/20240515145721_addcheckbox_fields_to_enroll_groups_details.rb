class AddcheckboxFieldsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :non_applicable_for_revalidation, :boolean, default: false
  end
end