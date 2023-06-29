class AddNewColumnsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def up
    add_column :enrollment_groups, :payer_contracts, :string
    add_column :enrollment_groups, :group_type_documents, :string
    add_column :enrollment_groups, :eft_file, :string
    add_column :enrollment_groups, :voided_check_file, :string
  end

  def down
    remove_column :enrollment_groups, :payer_contracts, :string
    remove_column :enrollment_groups, :group_type_documents, :string
    remove_column :enrollment_groups, :eft_file, :string
    remove_column :enrollment_groups, :voided_check_file, :string
  end
end
