class CreatePersonallyEmployedPractitioners < ActiveRecord::Migration[7.0]
  def change
    create_table :personally_employed_practitioners do |t|
      t.string :personal_employed_first_name
      t.string :personal_employed_last_name
      t.string :personal_employed_suffix_name
      t.string :personal_employed_state_license
      t.string :personal_employed_state_license_number
      t.references :practice_information, index: false
      t.timestamps
    end
    add_index  :personally_employed_practitioners, :practice_information_id, :name => 'pep_ppi_id'

  end
end
