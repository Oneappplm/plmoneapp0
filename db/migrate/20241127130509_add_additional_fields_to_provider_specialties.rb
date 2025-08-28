class AddAdditionalFieldsToProviderSpecialties < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_specialties, :applied_board_certificate, :string
    add_column :provider_specialties, :certification_name, :string
    add_column :provider_specialties, :date_applied, :date
    add_column :provider_specialties, :tickler, :string
    add_column :provider_specialties, :comments, :text
  end
end
