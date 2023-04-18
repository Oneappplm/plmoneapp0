class CreateProviderTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_taxonomies do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :taxonomy_code
      t.string :specialty

      t.timestamps
    end
  end
end
