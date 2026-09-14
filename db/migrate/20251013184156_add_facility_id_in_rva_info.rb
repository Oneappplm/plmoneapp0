class AddFacilityIdInRvaInfo < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations,
                  :provider_personal_information_facility,
                  foreign_key: true,
                  index: { name: 'idx_rva_info_facilities' }
    add_column :provider_personal_information_facilities, :audit_status, :string              
  end
end
