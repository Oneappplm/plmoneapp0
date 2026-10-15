class AddIndexToNestedForms < ActiveRecord::Migration[7.0]
  def change
    add_column :other_names, :temp_key, :integer
    add_column :provider_source_specialities, :temp_key, :integer
    add_column :provider_source_undergrad_schools, :temp_key, :integer
    add_index :other_names, [:provider_source_id, :temp_key], unique: true, name: "idx_other_names_on_psid_idx"
    add_index :provider_source_specialities, [:provider_source_id, :temp_key], unique: true, name: "idx_pss_on_psid_and_idx"
    add_index :provider_source_undergrad_schools, [:provider_source_id, :temp_key], unique: true, name: "idx_psus_on_psid_and_idx"
  end
end
