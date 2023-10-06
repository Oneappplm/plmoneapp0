class CreateProviderNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_notes do |t|
      t.references :provider
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
