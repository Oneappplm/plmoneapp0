class AddScheduleLimitExplanationToProviderSourcesCds < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_sources_cds, :schedule_limit_explanation, :text
  end
end
