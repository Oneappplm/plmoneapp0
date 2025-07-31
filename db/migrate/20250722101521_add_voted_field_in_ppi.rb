class AddVotedFieldInPpi < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :vote_date, :date 
    add_column :provider_personal_informations, :vote_by, :string 
  end
end
