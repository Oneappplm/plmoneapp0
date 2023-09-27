class RunImportScriptMethodResolutions < ActiveRecord::Migration[7.0]
  def change
    MethodResolution.generate_method_resolutions
  end
end
