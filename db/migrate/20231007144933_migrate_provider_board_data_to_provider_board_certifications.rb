class MigrateProviderBoardDataToProviderBoardCertifications < ActiveRecord::Migration[7.0]
  def up
    Provider.find_each do |provider|
      provider.board_certifications.find_or_create_by(
          bc_board_name: provider.board_name,
          bc_effective_date: provider.board_effective_date,
          bc_expiration_date: provider.board_expiration_date,
          bc_recertification_date: provider.board_recertification_date,
          bc_certification_number: provider.board_certificate_number,
          bc_specialty_type: provider.board_specialty_type

        )
    end
  end

  def down
    ProviderBoardCertification.delete_all
  end
end
