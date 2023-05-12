class AddEnrollmentPayerToEnrollGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups, :enrollment_payer, :string
  end
end
