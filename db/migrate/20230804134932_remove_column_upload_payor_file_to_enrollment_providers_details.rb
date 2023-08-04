class RemoveColumnUploadPayorFileToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :enrollment_providers_details, :upload_payor_file, :string
  end
end
