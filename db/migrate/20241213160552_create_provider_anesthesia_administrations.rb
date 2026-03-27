class CreateProviderAnesthesiaAdministrations < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_anesthesia_administrations do |t|
      t.string :first_name
      t.string :last_name
      t.string :suffix
      t.string :practitioner_type
      t.text :other_explaination
      t.boolean :is_class_a, default: false
      t.boolean :is_class_b, default: false
      t.boolean :is_class_c, default: false
      t.references :practice_information, index: false

      t.timestamps
    end
    add_index  :provider_anesthesia_administrations, :practice_information_id, :name => 'paa_ppi_id'
  end
end
