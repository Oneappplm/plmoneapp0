class ReplaceColumnInPsSpeciality < ActiveRecord::Migration[7.0]
  def change
    remove_column :provider_source_specialities, :ranking, :integer
    add_column :provider_source_specialities, :speciality_ranking, :string
  end
end
