class ChangeProviderSourceIdToNullableInProviderSourcesLicensure < ActiveRecord::Migration[7.0]
  def change
    change_column_null :provider_sources_licensure, :provider_source_id, true
  end
end
