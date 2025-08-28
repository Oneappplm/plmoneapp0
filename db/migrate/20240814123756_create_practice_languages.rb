class CreatePracticeLanguages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_languages do |t|
      t.integer       :caqh_provider_practice_language_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.string        :language_type
      t.string        :linguist_name
      t.string        :language_language_name
      t.text          :employee_type_employee_type_description
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_languages
  end
end
