class AddProviderPersonalInformationPeerRefToRvaInformation < ActiveRecord::Migration[6.1]
  def change
    add_reference :rva_informations,
                  :provider_personal_information_peer_ref,
                  foreign_key: true,
                  index: { name: 'idx_rva_info_peer_ref' }
  end
end
