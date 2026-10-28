class ChangeClaimAmountToStringInProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def up
    change_column :provider_insurance_coverages,
                  :claim_amount,
                  :string,
                  using: 'claim_amount::text'
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Text claim amounts cannot safely be converted to integers"
  end
end
