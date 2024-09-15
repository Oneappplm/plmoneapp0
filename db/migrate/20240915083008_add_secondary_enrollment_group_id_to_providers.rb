class AddSecondaryEnrollmentGroupIdToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :secondary_enrollment_group_id, :integer
    add_column :providers, :secondary_primary_location, :string
    add_column :providers, :secondary_dcos, :string, default: false
  end
end
