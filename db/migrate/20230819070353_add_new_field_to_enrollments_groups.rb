class AddNewFieldToEnrollmentsGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :w9_signed_date, :date
    add_column :enrollment_groups, :w9_sign_date_expiration, :date
    add_column :enrollment_groups, :void_check_signed_date, :date
    add_column :enrollment_groups, :void_check_date_expiration, :date
    add_column :enrollment_groups, :bank_letter_signed_date, :date
    add_column :enrollment_groups, :bank_letter_date_expiration, :date
  end
end
