class CreateProviderSectionApplicabilities < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_section_applicabilities do |t|
      t.references :provider_personal_information,
                   null: false,
                   foreign_key: true,
                   index: false

      t.string :section_key, null: false
      t.boolean :not_applicable, default: false, null: false
      t.text :explanation

      t.timestamps
    end

    add_index :provider_section_applicabilities,
              [:provider_personal_information_id, :section_key],
              unique: true,
              name: "idx_provider_section_applicability_unique"
  end
end