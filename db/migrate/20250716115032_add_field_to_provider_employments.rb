class AddFieldToProviderEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_employments, :caqh_provider_employment_id, :integer

    add_column :professional_organizations, :caqh_provider_professional_organization_id, :integer
    add_column :professional_organizations, :caqh_provider_attest_id, :integer

    add_reference :professional_organizations, :provider_attest, foreign_key: true
  end
end
