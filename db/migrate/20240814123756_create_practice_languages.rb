class CreatePracticeLanguages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_languages, primary_key: [:provider_attest_id,:provider_practice_language_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_language_id
      t.references    :provider_attest
      t.string        :language_type
      t.string        :linguist_name
      t.string        :language_language_name
      t.text          :employee_type_employee_type_description
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_languages, :provider_practice_id, :name => 'plang_pp_id'
  end

  def self.down
    drop_table :practice_languages
  end
end
