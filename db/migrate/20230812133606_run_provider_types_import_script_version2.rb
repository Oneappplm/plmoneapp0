class RunProviderTypesImportScriptVersion2 < ActiveRecord::Migration[7.0]
  def change
    Import::ProviderTypesService.call(Rails.root.join('lib', 'data', 'provider-types.xlsx'), 2)
  end
end
