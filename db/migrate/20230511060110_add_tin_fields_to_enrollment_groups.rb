class AddTinFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :tin_digit, :string
    add_column :enrollment_groups, :tin_digit_irs, :string
    add_column :enrollment_groups, :w9_file, :string
  end
end
