class CreateDisclosureCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :disclosure_categories do |t|
      t.string :title
      t.string :note
      t.string :alert_type

      t.timestamps
    end
  end
end
