class CreateGroupDcoProviderOutreachInformations < ActiveRecord::Migration[7.0]
  def change
    create_table :group_dco_provider_outreach_informations do |t|
      t.references :group_dco
      t.string :name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :position

      t.timestamps
    end
  end
end
