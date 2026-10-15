class AddFormTypeToProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_insurance_coverages, :form_type, :string
  end
end
