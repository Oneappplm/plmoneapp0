class CreateProfessionalOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :professional_organizations do |t|
        t.string :prof_organization_name, null: false
        t.date :prof_org_effected_date, null: false
        t.date :prof_org_termination_date, null: false
        t.boolean :prof_org_until_current, default: false
      t.timestamps
    end
  end
end
