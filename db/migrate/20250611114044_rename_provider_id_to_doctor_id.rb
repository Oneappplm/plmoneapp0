class RenameProviderIdToDoctorId < ActiveRecord::Migration[7.0]
  def change
    rename_column :patients, :provider_id, :doctor_id
    rename_column :appointments, :provider_id, :doctor_id
    rename_column :invoices, :provider_id, :doctor_id
  end
end
