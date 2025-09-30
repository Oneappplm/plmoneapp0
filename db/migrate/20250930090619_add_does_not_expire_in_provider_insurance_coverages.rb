class AddDoesNotExpireInProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_insurance_coverages, :prof_liability_does_not_expire, :boolean
  end
end
