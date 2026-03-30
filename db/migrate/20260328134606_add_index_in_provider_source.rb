class AddIndexInProviderSource < ActiveRecord::Migration[7.0]
  def change
    add_index :provider_sources,
      [:group_engage_provider_id, :current_provider_source],
      unique: true,
      where: "current_provider_source = true",
      name: "idx_ps_on_gep_and_current"
  end
end
