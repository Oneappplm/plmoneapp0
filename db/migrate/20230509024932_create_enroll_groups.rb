class CreateEnrollGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :enroll_groups do |t|
      t.string :name
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :email
      t.string :telephone_number
      t.string :medicare_ptan
      t.string :medicaid_group_number
      t.string :bcbs_number
      t.string :tricate_military
      t.string :commercial_name
      t.string :contracted
      t.string :revalidated
      t.string :revalidated_payer_name
      t.string :application_contracts
      t.string :application_payer_name
      t.string :with_medicare
      t.string :with_eft
      t.string :with_edi
      t.datetime :start_date
      t.datetime :due_date
      t.string :payer
      t.datetime :revalidation_date
      t.string :enrollment_type
      t.string :status

      t.timestamps
    end
  end
end
