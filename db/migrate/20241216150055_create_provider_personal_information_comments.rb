class CreateProviderPersonalInformationComments < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_comments do |t|
      t.references :provider_personal_information, null: false, foreign_key: true, index: false
      t.string :subject
      t.text :message
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index  :provider_personal_information_comments, :provider_personal_information_id, :name => 'ppi_id_ppi_c'
  end
end
