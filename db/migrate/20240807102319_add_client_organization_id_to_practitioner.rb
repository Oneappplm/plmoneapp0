class AddClientOrganizationIdToPractitioner < ActiveRecord::Migration[7.0]
  def change
    add_reference :practitioners, :client_organization, foreign_key: true
  end
end
