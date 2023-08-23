class RunProviderTypesImportScriptVersion3 < ActiveRecord::Migration[7.0]
  def change
    Import::ProviderTypesService.call(Rails.root.join('lib', 'data', 'provider-types-v3.xlsx'), 3)
  end
end
