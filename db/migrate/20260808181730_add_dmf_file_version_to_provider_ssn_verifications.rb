class AddDmfFileVersionToProviderSsnVerifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :provider_ssn_verifications,
                  :dmf_file_version,
                  null: true,
                  foreign_key: true
  end
end