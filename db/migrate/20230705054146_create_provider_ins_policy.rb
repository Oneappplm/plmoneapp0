class CreateProviderInsPolicy < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_ins_policies do |t|
      t.references :provider
      t.string :ins_policy_number
      t.datetime :effective_date
      t.datetime :expiration_date

      t.timestamps
    end
  end

  def down
    drop_table :provider_ins_policies
  end
end
