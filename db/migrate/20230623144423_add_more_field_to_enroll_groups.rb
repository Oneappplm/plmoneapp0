class AddMoreFieldToEnrollGroups < ActiveRecord::Migration[7.0]
  def change
  add_column :enroll_groups, :voided_bank_letter, :string
  end
end
