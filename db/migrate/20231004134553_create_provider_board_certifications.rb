class CreateProviderBoardCertifications < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_board_certifications do |t|
      t.references :provider
      t.string :bc_board_certification
      t.string :bc_board_name
      t.string :bc_certification_number
      t.string :bc_specialty_type
      t.datetime :bc_effective_date
      t.datetime :bc_expiration_date
      t.datetime :bc_recertification_date
      t.timestamps
    end
  end
end
